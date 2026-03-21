---
id: 20260309092903
tags:
  - IT文档
created: 2026-03-09 09:29
---

```
<script>
(function () {
  'use strict';
  if (window.__komariFinanceVisitorFinalLoaded__) return;
  window.__komariFinanceVisitorFinalLoaded__ = true;

  const DAY_MS = 86400000;

  const CONFIG = {
    exchangeApi: 'https://open.er-api.com/v6/latest/CNY',
    refreshInterval: 10 * 60 * 1000,
    monthDays: 30.4375,
    longTermYears: 20,
    nodeEndpoints: ['/api/nodes', '/api/v1/nodes', '/api/service/nodes', '/api/user/nodes'],
    visitorEndpoint: '/api/welcome-info',
    visitorAutoShow: true
  };

  const state = {
    nodes: [],
    rates: { CNY: 1, USD: 0.14, EUR: 0.13, HKD: 1.08, GBP: 0.11, JPY: 21 },
    lastRateUpdate: null,
    currency: 'CNY',
    sortKey: 'remaining',
    sortAsc: false,
    keyword: '',
    loading: false,
    visitor: {}
  };

  function pick(obj, keys, fallback) {
    for (const key of keys) {
      if (obj && obj[key] !== undefined && obj[key] !== null) return obj[key];
    }
    return fallback;
  }

  function parseNumber(value, fallback = NaN) {
    if (typeof value === 'number') return Number.isFinite(value) ? value : fallback;
    if (typeof value === 'string') {
      const cleaned = value.replace(/[^\d.\-]/g, '');
      const n = parseFloat(cleaned);
      return Number.isFinite(n) ? n : fallback;
    }
    return fallback;
  }

  function parseDateSafe(value) {
    if (!value) return null;
    if (value instanceof Date) return isNaN(value.getTime()) ? null : value;

    const s = String(value).trim();
    if (!s) return null;

    if (/^\d+$/.test(s)) {
      const n = Number(s);
      const ms = n > 1e12 ? n : n * 1000;
      const d = new Date(ms);
      return isNaN(d.getTime()) ? null : d;
    }

    const d = new Date(s);
    return isNaN(d.getTime()) ? null : d;
  }

  function normalizeCurrency(raw) {
    const s = String(raw || '').trim().toUpperCase();
    if (!s || s === '¥' || s === 'RMB' || s === 'CNY') return 'CNY';
    if (s === '$' || s === 'USD') return 'USD';
    if (s === '€' || s === 'EUR') return 'EUR';
    if (s === 'HK$' || s === 'HKD') return 'HKD';
    if (s === '£' || s === 'GBP') return 'GBP';
    if (s === 'JPY' || s === 'JP¥') return 'JPY';
    return s;
  }

  function getSymbol(code) {
    if (code === 'CNY') return '¥';
    if (code === 'USD') return '$';
    if (code === 'EUR') return '€';
    if (code === 'HKD') return 'HK$';
    if (code === 'GBP') return '£';
    if (code === 'JPY') return '¥';
    return code + ' ';
  }

  function formatMoney(value, currency) {
    const safe = Number.isFinite(value) ? value : 0;
    return getSymbol(currency) + safe.toFixed(2);
  }

  function formatTime(ts) {
    if (!ts) return '--';
    const d = new Date(ts);
    const pad = n => String(n).padStart(2, '0');
    return pad(d.getHours()) + ':' + pad(d.getMinutes()) + ':' + pad(d.getSeconds());
  }

  function escapeHtml(str) {
    return String(str ?? '')
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
  }

  function toCNY(amount, fromCurrency) {
    const n = Number.isFinite(amount) ? amount : 0;
    const cur = normalizeCurrency(fromCurrency);
    if (cur === 'CNY') return n;
    const rate = state.rates[cur];
    return rate ? n / rate : n;
  }

  function fromCNY(amount, targetCurrency) {
    const n = Number.isFinite(amount) ? amount : 0;
    if (targetCurrency === 'CNY') return n;
    const rate = state.rates[targetCurrency];
    return rate ? n * rate : n;
  }

  function parseCycleDays(cycleRaw, unitRaw, priceText) {
    const unit = String(unitRaw || '').toLowerCase();
    const cycleNum = parseNumber(cycleRaw, NaN);

    if (Number.isFinite(cycleNum) && cycleNum > 0) {
      if (/year|annual|yr|年/.test(unit)) return cycleNum * 365.25;
      if (/quarter|季/.test(unit)) return cycleNum * (365.25 / 4);
      if (/month|mo|月/.test(unit)) return cycleNum * CONFIG.monthDays;
      if (/week|wk|周/.test(unit)) return cycleNum * 7;
      if (/day|d|天|日/.test(unit)) return cycleNum;
      return cycleNum;
    }

    const t = String(priceText || '').toLowerCase();
    if (/\/\s*year|\/\s*yr|\/\s*annual|\/年/.test(t)) return 365.25;
    if (/\/\s*quarter|\/季/.test(t)) return 365.25 / 4;
    if (/\/\s*month|\/\s*mo|\/月/.test(t)) return CONFIG.monthDays;
    if (/\/\s*week|\/\s*wk|\/周/.test(t)) return 7;
    if (/\/\s*day|\/天|\/日/.test(t)) return 1;

    return CONFIG.monthDays;
  }

  function extractPriceAndCurrency(raw) {
    const directPrice = pick(raw, ['price', 'amount', 'billing_price', 'month_price', 'monthly_price'], null);
    const directCurrency = pick(raw, ['currency', 'currency_code'], 'CNY');
    let price = parseNumber(directPrice, NaN);
    let currency = normalizeCurrency(directCurrency);
    const text = String(directPrice ?? '');

    if (!Number.isFinite(price)) price = 0;
    if (price < 0 && price !== -1) price = 0;

    return { price, currency, text };
  }

  function isOneTimeNode(raw, priceText, name) {
    const texts = [
      name,
      priceText,
      pick(raw, ['period', 'billing_cycle', 'cycle', 'cycle_unit', 'period_unit', 'billing_unit'], ''),
      pick(raw, ['remark', 'note', 'desc', 'description', 'tag'], '')
    ]
      .map(v => String(v || '').toLowerCase())
      .join(' | ');

    return /一次性|一?次付|买断|永久|终身|lifetime|one[-\s]?time|founder|创始人款/.test(texts);
  }

  function detectScale(items) {
    const vals = items
      .map(item => item.rawPrice)
      .filter(v => Number.isFinite(v) && v > 0 && v < 1e10)
      .sort((a, b) => a - b);

    if (!vals.length) return 1;

    const p50 = vals[Math.floor(vals.length * 0.5)];
    const p90 = vals[Math.floor(vals.length * 0.9)];

    if (p50 >= 1000 && p90 >= 10000) return 0.01;
    return 1;
  }

  function normalizeNode(raw, scale) {
    const name = String(pick(raw, ['name', 'title', 'server_name', 'plan_name', 'product_name'], 'Unnamed'));
    const quantity = Math.max(1, parseNumber(pick(raw, ['quantity', 'count'], 1), 1));

    const priceInfo = extractPriceAndCurrency(raw);
    const priceRaw = priceInfo.price;
    const isOneTime = isOneTimeNode(raw, priceInfo.text, name);
    const isSpecialFree = priceRaw === -1 || priceRaw === 0;

    const safePrice = priceRaw < 0 ? 0 : priceRaw;
    const normalizedPrice = safePrice > 1e10 ? 0 : safePrice * scale;

    const cycleRaw = pick(raw, ['billing_cycle', 'cycle', 'period', 'billing_days'], null);
    const cycleUnitRaw = pick(raw, ['cycle_unit', 'period_unit', 'billing_unit'], null);
    const cycleDays = isOneTime ? 0 : parseCycleDays(cycleRaw, cycleUnitRaw, priceInfo.text);

    const tradeRaw = pick(raw, ['trade_price', 'sale_price', 'transaction_price', 'paid_price', 'buy_price', 'sell_price'], null);
    const tradePrice = parseNumber(tradeRaw, NaN);
    const hasTrade = Number.isFinite(tradePrice);
    const tradePriceScaled = hasTrade ? Math.max(0, tradePrice) * scale : 0;

    const expiredAt = pick(raw, [
      'expired_at',
      'expire_at',
      'expiration_date',
      'due_date',
      'expire_time',
      'next_billing_at',
      'end_at'
    ], null);

    return {
      name,
      quantity,
      isOneTime,
      isSpecialFree,
      cycleDays: cycleDays > 0 ? cycleDays : 0,
      expiredAt,
      priceCNY: toCNY(normalizedPrice, priceInfo.currency) * quantity,
      hasTrade,
      tradePriceCNY: toCNY(tradePriceScaled, priceInfo.currency),
      rawPrice: normalizedPrice
    };
  }

  function getRemainingMs(node, now) {
    const expire = parseDateSafe(node.expiredAt);
    if (!expire) return 0;
    return expire.getTime() - now.getTime();
  }

  function calcRemaining(node, now) {
    const diff = getRemainingMs(node, now);

    if (node.isOneTime) {
      if (!node.expiredAt) return { valueCNY: node.priceCNY, isLongTerm: true };
      return diff > 0
        ? { valueCNY: node.priceCNY, isLongTerm: true }
        : { valueCNY: 0, isLongTerm: true };
    }

    if (diff <= 0) return { valueCNY: 0, isLongTerm: false };

    const years = diff / (365.25 * DAY_MS);
    if (years > CONFIG.longTermYears) {
      return { valueCNY: node.priceCNY, isLongTerm: true };
    }

    const cycleMs = node.cycleDays * DAY_MS;
    if (cycleMs <= 0) return { valueCNY: 0, isLongTerm: false };

    const ratio = Math.min(1, Math.max(0, diff / cycleMs));
    return { valueCNY: node.priceCNY * ratio, isLongTerm: false };
  }

  function calcMonthlyCNY(node) {
    if (node.isOneTime) return 0;
    const months = node.cycleDays / CONFIG.monthDays;
    return months > 0 ? node.priceCNY / months : 0;
  }

  function calcPremium(node, now) {
    const remain = calcRemaining(node, now).valueCNY;
    if (!node.hasTrade || remain <= 0) return { canShow: false, premium: 0, rate: 0 };

    const premium = node.tradePriceCNY - remain;
    return { canShow: true, premium, rate: premium / remain };
  }

  function summarize() {
    const now = new Date();
    let originalValueCNY = 0;
    let monthlyCNY = 0;
    let yearlyCNY = 0;
    let remainingCNY = 0;

    for (const node of state.nodes) {
      if (!node.isSpecialFree) {
        originalValueCNY += node.priceCNY;
        monthlyCNY += calcMonthlyCNY(node);
        remainingCNY += calcRemaining(node, now).valueCNY;
      }
    }

    yearlyCNY = monthlyCNY * 12;

    return {
      totalCount: state.nodes.length,
      originalValue: fromCNY(originalValueCNY, state.currency),
      monthly: fromCNY(monthlyCNY, state.currency),
      yearly: fromCNY(yearlyCNY, state.currency),
      remaining: fromCNY(remainingCNY, state.currency)
    };
  }

  async function fetchExchangeRates() {
    try {
      const res = await fetch(CONFIG.exchangeApi, { cache: 'no-store' });
      const data = await res.json();
      if (data?.result === 'success' && data?.rates) {
        state.rates = { ...state.rates, ...data.rates };
        state.lastRateUpdate = Date.now();
      }
    } catch (_) {}
  }

  async function fetchNodes() {
    let best = [];

    for (const url of CONFIG.nodeEndpoints) {
      try {
        const res = await fetch(url, {
          credentials: 'include',
          headers: { Accept: 'application/json' }
        });
        if (!res.ok) continue;

        const data = await res.json();
        const list = Array.isArray(data) ? data
          : Array.isArray(data?.data) ? data.data
          : Array.isArray(data?.nodes) ? data.nodes
          : Array.isArray(data?.list) ? data.list
          : [];

        if (list.length > best.length) best = list;
      } catch (_) {}
    }

    const pre = best.map(raw => {
      const priceInfo = extractPriceAndCurrency(raw);
      return { raw, rawPrice: priceInfo.price };
    });

    const scale = detectScale(pre);
    state.nodes = pre.map(item => normalizeNode(item.raw, scale));
  }

  function mapVisitor(raw) {
    const d = raw?.data || raw?.result || raw || {};
    return {
      city: d.city || '',
      region: d.region || '',
      country: d.country || d.country_name || '',
      ip: d.ip || '',
      org: d.org || '',
      os: d.os || '',
      browser: d.browser || ''
    };
  }

  async function fetchVisitor() {
    try {
      const res = await fetch(CONFIG.visitorEndpoint, { credentials: 'include' });
      if (res.ok) {
        const data = await res.json();
        const info = mapVisitor(data);
        if (info.city || info.region || info.ip) return info;
      }
    } catch (_) {}

    try {
      const res = await fetch('https://ipapi.co/json/');
      if (res.ok) {
        const data = await res.json();
        return {
          city: data.city || '',
          region: data.region || '',
          country: data.country_name || data.country || '',
          ip: data.ip || '',
          org: data.org || '',
          os: '',
          browser: ''
        };
      }
    } catch (_) {}

    return {};
  }

  function detectUA() {
    const ua = navigator.userAgent || '';
    const os = /Mac/i.test(ua) ? 'macOS' : /Windows/i.test(ua) ? 'Windows' : /Linux/i.test(ua) ? 'Linux' : 'Unknown OS';
    const browser = /Chrome/i.test(ua) ? 'Chrome 浏览器' : /Safari/i.test(ua) ? 'Safari 浏览器' : /Firefox/i.test(ua) ? 'Firefox 浏览器' : 'Unknown Browser';
    return { os, browser };
  }

  function ensureStyles() {
    if (document.getElementById('kfv-style')) return;

    const style = document.createElement('style');
    style.id = 'kfv-style';
    style.textContent = `
      :root{
        --kfv-accent:#635bda;
        --kfv-accent-strong:#5146d8;
        --kfv-text:#1f2430;
        --kfv-sub:#667085;
        --kfv-line:rgba(99,91,218,.14);
        --kfv-line-strong:rgba(99,91,218,.22);
        --kfv-bg:rgba(255,255,255,.78);
        --kfv-bg-strong:rgba(255,255,255,.92);
        --kfv-shadow:0 24px 60px rgba(41,34,84,.18);
        --kfv-shadow-soft:0 10px 30px rgba(41,34,84,.12);
        --kfv-radius:24px;
        --kfv-radius-sm:14px;
      }

      #kfv-fab{
        position:fixed;
        right:20px;
        bottom:20px;
        z-index:99999;
        width:48px;
        height:48px;
        border:none;
        border-radius:50%;
        background:linear-gradient(135deg,var(--kfv-accent),#7a72ea);
        color:#fff;
        font-size:20px;
        cursor:pointer;
        box-shadow:0 12px 30px rgba(99,91,218,.34);
        transition:transform .18s ease, box-shadow .18s ease;
      }
      #kfv-fab:hover{
        transform:translateY(-2px);
        box-shadow:0 16px 34px rgba(99,91,218,.40);
      }

      #kfv-mask{
        position:fixed;
        inset:0;
        z-index:99998;
        background:rgba(18,18,30,.18);
        backdrop-filter:blur(4px);
        display:none;
      }

      #kfv-panel{
        position:fixed;
        left:50%;
        top:50%;
        transform:translate(-50%,-50%);
        width:min(720px,calc(100vw - 28px));
        max-height:86vh;
        background:var(--kfv-bg);
        backdrop-filter:blur(16px) saturate(140%);
        -webkit-backdrop-filter:blur(16px) saturate(140%);
        border:1px solid rgba(255,255,255,.65);
        border-radius:var(--kfv-radius);
        overflow:hidden;
        display:none;
        z-index:99999;
        box-shadow:var(--kfv-shadow);
        font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"PingFang SC","Microsoft YaHei",sans-serif;
        color:var(--kfv-text);
      }
      #kfv-panel *{ box-sizing:border-box; }

      .kfv-hd{
        display:flex;
        align-items:center;
        justify-content:space-between;
        padding:18px 22px 14px;
        border-bottom:1px solid var(--kfv-line);
        background:linear-gradient(180deg,rgba(255,255,255,.38),rgba(255,255,255,0));
      }

      .kfv-title{
        font-size:20px;
        font-weight:800;
        letter-spacing:.2px;
        color:var(--kfv-accent);
      }

      .kfv-close{
        width:38px;
        height:38px;
        border:none;
        background:rgba(255,255,255,.58);
        border-radius:12px;
        font-size:24px;
        line-height:1;
        cursor:pointer;
        color:#5f6472;
        box-shadow:inset 0 0 0 1px rgba(99,91,218,.10);
        transition:background .18s ease, transform .18s ease;
      }
      .kfv-close:hover{
        background:#fff;
        transform:scale(1.03);
      }

      .kfv-summary{
        padding:18px 22px 8px;
        display:grid;
        grid-template-columns:repeat(2,minmax(0,1fr));
        gap:12px;
      }

      .kfv-row{
        display:flex;
        flex-direction:column;
        gap:6px;
        padding:14px 16px;
        border-radius:18px;
        background:rgba(255,255,255,.72);
        box-shadow:var(--kfv-shadow-soft);
        border:1px solid rgba(99,91,218,.10);
        min-width:0;
      }

      .kfv-row span:first-child{
        font-size:12px;
        color:var(--kfv-sub);
        line-height:1.2;
      }

      .kfv-v{
        font-size:24px;
        font-weight:800;
        line-height:1.1;
        color:var(--kfv-accent-strong);
        letter-spacing:-.02em;
        word-break:break-all;
      }

      .kfv-toolbar{
        padding:14px 22px 14px;
        display:flex;
        gap:10px;
        flex-wrap:wrap;
        border-top:1px solid var(--kfv-line);
        border-bottom:1px solid var(--kfv-line);
        background:rgba(255,255,255,.34);
      }

      .kfv-in,.kfv-sel,.kfv-btn{
        height:40px;
        padding:0 14px;
        border:1px solid var(--kfv-line-strong);
        border-radius:14px;
        background:rgba(255,255,255,.86);
        color:var(--kfv-text);
        font-size:14px;
        outline:none;
        box-shadow:0 2px 10px rgba(99,91,218,.05);
        transition:border-color .18s ease, box-shadow .18s ease, background .18s ease;
      }

      .kfv-in:focus,.kfv-sel:focus,.kfv-btn:hover{
        border-color:rgba(99,91,218,.34);
        box-shadow:0 0 0 4px rgba(99,91,218,.08);
        background:#fff;
      }

      .kfv-in{
        flex:1;
        min-width:180px;
      }

      .kfv-list{
        padding:6px 22px 0;
        max-height:42vh;
        overflow:auto;
      }

      .kfv-list::-webkit-scrollbar{
        width:8px;
      }
      .kfv-list::-webkit-scrollbar-thumb{
        background:rgba(99,91,218,.18);
        border-radius:999px;
      }

      .kfv-item{
        padding:14px 0;
        border-bottom:1px solid rgba(99,91,218,.08);
      }

      .kfv-main{
        display:flex;
        justify-content:space-between;
        align-items:flex-start;
        gap:12px;
        font-size:16px;
      }

      .kfv-name{
        max-width:68%;
        font-size:16px;
        font-weight:700;
        line-height:1.35;
        color:var(--kfv-text);
        overflow:hidden;
        display:-webkit-box;
        -webkit-line-clamp:2;
        -webkit-box-orient:vertical;
        white-space:normal;
      }

      .kfv-price{
        flex:0 0 auto;
        font-size:18px;
        font-weight:800;
        color:var(--kfv-accent-strong);
        letter-spacing:-.01em;
      }

      .kfv-sub{
        margin-top:8px;
        display:flex;
        gap:8px;
        flex-wrap:wrap;
        font-size:12px;
        color:var(--kfv-sub);
        line-height:1.6;
      }

      .kfv-sub span{
        padding:3px 0;
      }

      .kfv-badge{
        display:inline-flex;
        align-items:center;
        padding:3px 9px;
        border-radius:999px;
        font-size:11px;
        font-weight:700;
        border:1px solid transparent;
      }

      .kfv-gray{
        background:rgba(116,123,143,.10);
        color:#6b7280;
        border-color:rgba(116,123,143,.10);
      }

      .kfv-red{
        background:rgba(255,92,92,.10);
        color:#cf3341;
        border-color:rgba(255,92,92,.12);
      }

      .kfv-green{
        background:rgba(44,187,99,.11);
        color:#228a51;
        border-color:rgba(44,187,99,.12);
      }

      .kfv-ft{
        padding:12px 22px 16px;
        border-top:1px solid var(--kfv-line);
        background:rgba(255,255,255,.34);
      }

      .kfv-note{
        font-size:12px;
        color:#7a8090;
        text-align:right;
      }

      #kfv-visitor-btn{
        position:fixed;
        left:16px;
        bottom:16px;
        z-index:99990;
        width:40px;
        height:40px;
        border:none;
        border-radius:50%;
        background:linear-gradient(135deg,var(--kfv-accent),#7a72ea);
        color:#fff;
        font-size:18px;
        cursor:pointer;
        box-shadow:0 10px 24px rgba(99,91,218,.30);
      }

      #kfv-visitor{
        position:fixed;
        left:16px;
        bottom:64px;
        z-index:99990;
        width:min(320px,calc(100vw - 20px));
        background:var(--kfv-bg-strong);
        backdrop-filter:blur(12px) saturate(140%);
        -webkit-backdrop-filter:blur(12px) saturate(140%);
        border:1px solid rgba(255,255,255,.72);
        border-radius:20px;
        box-shadow:var(--kfv-shadow-soft);
        display:none;
        overflow:hidden;
        font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"PingFang SC","Microsoft YaHei",sans-serif;
      }

      .kfv-v-hd{
        display:flex;
        justify-content:space-between;
        align-items:center;
        padding:12px 14px;
        border-bottom:1px solid var(--kfv-line);
      }

      .kfv-v-title{
        font-size:16px;
        font-weight:800;
        color:var(--kfv-accent);
      }

      .kfv-v-x{
        width:32px;
        height:32px;
        border:none;
        background:rgba(255,255,255,.64);
        border-radius:10px;
        font-size:22px;
        line-height:1;
        color:#444;
        cursor:pointer;
      }

      .kfv-v-bd{
        padding:12px 14px;
      }

      .kfv-v-w{
        font-size:14px;
        color:var(--kfv-text);
        margin-bottom:8px;
        line-height:1.6;
      }

      .kfv-v-line{
        display:flex;
        align-items:flex-start;
        gap:10px;
        font-size:12px;
        color:#374151;
        line-height:1.85;
        word-break:break-word;
        overflow-wrap:anywhere;
      }

      .kfv-v-icon{
        width:14px;
        flex:0 0 14px;
        text-align:center;
        color:#667085;
      }

      @media (max-width: 760px){
        #kfv-panel{
          width:calc(100vw - 18px);
          max-height:90vh;
          border-radius:20px;
        }

        .kfv-summary{
          grid-template-columns:1fr;
          gap:10px;
          padding:14px 16px 8px;
        }

        .kfv-toolbar{
          padding:12px 16px;
        }

        .kfv-list{
          padding:4px 16px 0;
          max-height:44vh;
        }

        .kfv-ft,.kfv-hd{
          padding-left:16px;
          padding-right:16px;
        }

        .kfv-v{
          font-size:22px;
        }

        .kfv-main{
          flex-direction:column;
          align-items:flex-start;
        }

        .kfv-name{
          max-width:100%;
        }

        .kfv-price{
          font-size:20px;
        }

        .kfv-in{
          min-width:100%;
        }
      }
    `;
    document.head.appendChild(style);
  }

  function ensureDOM() {
    ensureStyles();

    if (!document.getElementById('kfv-fab')) {
      const fab = document.createElement('button');
      fab.id = 'kfv-fab';
      fab.type = 'button';
      fab.textContent = '¤';
      fab.title = '资产统计';
      fab.onclick = openFinance;
      document.body.appendChild(fab);
    }

    if (!document.getElementById('kfv-mask')) {
      const mask = document.createElement('div');
      mask.id = 'kfv-mask';
      mask.onclick = closeFinance;
      document.body.appendChild(mask);
    }

    if (!document.getElementById('kfv-panel')) {
      const panel = document.createElement('div');
      panel.id = 'kfv-panel';
      panel.innerHTML = `
        <div class="kfv-hd"><div class="kfv-title">资产统计</div><button class="kfv-close" type="button">×</button></div>
        <div class="kfv-summary"></div>
        <div class="kfv-toolbar">
          <input class="kfv-in" id="kfv-search" placeholder="搜索节点名称">
          <select class="kfv-sel" id="kfv-currency">
            <option value="CNY">CNY (¥)</option>
            <option value="USD">USD ($)</option>
            <option value="EUR">EUR (€)</option>
            <option value="HKD">HKD (HK$)</option>
            <option value="GBP">GBP (£)</option>
          </select>
          <select class="kfv-sel" id="kfv-sort">
            <option value="remaining">按剩余价值</option>
            <option value="monthly">按月成本</option>
            <option value="name">按名称</option>
          </select>
          <button class="kfv-btn" id="kfv-order" type="button">倒序</button>
          <button class="kfv-btn" id="kfv-refresh" type="button">刷新</button>
        </div>
        <div class="kfv-list"></div>
        <div class="kfv-ft"><div class="kfv-note" id="kfv-note">汇率更新: --</div></div>
      `;
      panel.querySelector('.kfv-close').onclick = closeFinance;
      panel.querySelector('#kfv-currency').onchange = e => {
        state.currency = e.target.value;
        renderFinance();
      };
      panel.querySelector('#kfv-sort').onchange = e => {
        state.sortKey = e.target.value;
        renderFinance();
      };
      panel.querySelector('#kfv-order').onclick = function () {
        state.sortAsc = !state.sortAsc;
        renderFinance();
      };
      panel.querySelector('#kfv-search').oninput = e => {
        state.keyword = e.target.value.trim().toLowerCase();
        renderFinance();
      };
      panel.querySelector('#kfv-refresh').onclick = refreshAll;
      document.body.appendChild(panel);
    }

    if (!document.getElementById('kfv-visitor-btn')) {
      const btn = document.createElement('button');
      btn.id = 'kfv-visitor-btn';
      btn.type = 'button';
      btn.textContent = 'i';
      btn.title = '访客信息';
      btn.onclick = openVisitor;
      document.body.appendChild(btn);
    }

    if (!document.getElementById('kfv-visitor')) {
      const box = document.createElement('div');
      box.id = 'kfv-visitor';
      box.innerHTML = `
        <div class="kfv-v-hd"><div class="kfv-v-title">阿米诺斯</div><button class="kfv-v-x" type="button">×</button></div>
        <div class="kfv-v-bd" id="kfv-visitor-body">加载中...</div>
      `;
      box.querySelector('.kfv-v-x').onclick = closeVisitor;
      document.body.appendChild(box);
    }

    if (!window.__kfvEscBound__) {
      window.__kfvEscBound__ = true;
      document.addEventListener('keydown', e => {
        if (e.key === 'Escape') {
          closeFinance();
          closeVisitor();
        }
      });
    }
  }

  function openFinance() {
    ensureDOM();
    document.getElementById('kfv-mask').style.display = 'block';
    document.getElementById('kfv-panel').style.display = 'block';
  }

  function closeFinance() {
    const mask = document.getElementById('kfv-mask');
    const panel = document.getElementById('kfv-panel');
    if (mask) mask.style.display = 'none';
    if (panel) panel.style.display = 'none';
  }

  function openVisitor() {
    ensureDOM();
    document.getElementById('kfv-visitor').style.display = 'block';
  }

  function closeVisitor() {
    const visitor = document.getElementById('kfv-visitor');
    if (visitor) visitor.style.display = 'none';
  }

  function renderVisitor() {
    const body = document.getElementById('kfv-visitor-body');
    if (!body) return;

    const ua = detectUA();
    const v = state.visitor || {};
    const location = [v.city, v.region].filter(Boolean).join(', ') || '未知地区';
    const now = new Date();
    const dateText = `${now.getFullYear()}年${now.getMonth() + 1}月${now.getDate()}日`;

    const lines = [];
    lines.push(`<div class="kfv-v-line"><span class="kfv-v-icon"></span><span>${escapeHtml(v.os || ua.os)}</span></div>`);
    lines.push(`<div class="kfv-v-line"><span class="kfv-v-icon">◎</span><span>${escapeHtml(v.browser || ua.browser)}</span></div>`);
    if (v.ip) lines.push(`<div class="kfv-v-line"><span class="kfv-v-icon">◉</span><span>${escapeHtml(v.ip)}</span></div>`);
    if (v.org) lines.push(`<div class="kfv-v-line"><span class="kfv-v-icon">◌</span><span>${escapeHtml(v.org)}</span></div>`);
    lines.push(`<div class="kfv-v-line"><span class="kfv-v-icon">◷</span><span>${escapeHtml(dateText)}</span></div>`);

    body.innerHTML = `
      <div class="kfv-v-w">欢迎来自 ${escapeHtml(location)} 的朋友！</div>
      ${lines.join('')}
    `;
  }

  function sortNodes(nodes, now) {
    return [...nodes].sort((a, b) => {
      if (state.sortKey === 'name') {
        const result = a.name.localeCompare(b.name, 'zh-Hans-CN');
        return state.sortAsc ? result : -result;
      }

      const va = state.sortKey === 'monthly' ? calcMonthlyCNY(a) : calcRemaining(a, now).valueCNY;
      const vb = state.sortKey === 'monthly' ? calcMonthlyCNY(b) : calcRemaining(b, now).valueCNY;
      return state.sortAsc ? va - vb : vb - va;
    });
  }

  function renderFinance() {
    ensureDOM();

    const panel = document.getElementById('kfv-panel');
    if (!panel) return;

    const now = new Date();
    const summary = summarize();

    panel.querySelector('.kfv-summary').innerHTML = `
      <div class="kfv-row"><span>服务器数量</span><span class="kfv-v">${summary.totalCount}</span></div>
      <div class="kfv-row"><span>原始总投入</span><span class="kfv-v">${formatMoney(summary.originalValue, state.currency)}</span></div>
      <div class="kfv-row"><span>月均支出</span><span class="kfv-v">${formatMoney(summary.monthly, state.currency)}</span></div>
      <div class="kfv-row"><span>年度支出</span><span class="kfv-v">${formatMoney(summary.yearly, state.currency)}</span></div>
      <div class="kfv-row"><span>剩余总价值</span><span class="kfv-v">${formatMoney(summary.remaining, state.currency)}</span></div>
    `;

    panel.querySelector('#kfv-note').textContent =
      (state.loading ? '刷新中...  ' : '') + '汇率更新: ' + formatTime(state.lastRateUpdate);

    panel.querySelector('#kfv-order').textContent = state.sortAsc ? '正序' : '倒序';
    panel.querySelector('#kfv-currency').value = state.currency;
    panel.querySelector('#kfv-sort').value = state.sortKey;

    let list = state.nodes;
    if (state.keyword) list = list.filter(node => node.name.toLowerCase().includes(state.keyword));
    list = sortNodes(list, now);

    panel.querySelector('.kfv-list').innerHTML = list.map(node => {
      const remainInfo = calcRemaining(node, now);
      const remainDisplay = fromCNY(remainInfo.valueCNY, state.currency);
      const monthlyDisplay = fromCNY(calcMonthlyCNY(node), state.currency);
      const remainDays = Math.max(0, getRemainingMs(node, now) / DAY_MS);
      const cycleText = node.isOneTime ? '一次性' : (node.cycleDays.toFixed(1) + '天');
      const monthlyText = node.isOneTime ? '一次性付费' : ('月价: ' + formatMoney(monthlyDisplay, state.currency));

      let badges = '';
      if (node.isSpecialFree) badges += '<span class="kfv-badge kfv-gray">免费</span>';
      if (node.isOneTime) badges += '<span class="kfv-badge kfv-gray">一次性</span>';
      if (remainInfo.isLongTerm) badges += '<span class="kfv-badge kfv-gray">长期按原价</span>';

      const premium = calcPremium(node, now);
      if (premium.canShow) {
        badges += `<span class="kfv-badge ${premium.premium > 0 ? 'kfv-red' : 'kfv-green'}">${premium.premium > 0 ? '溢价' : '折价'} ${formatMoney(fromCNY(Math.abs(premium.premium), state.currency), state.currency)} (${Math.abs(premium.rate * 100).toFixed(1)}%)</span>`;
      }

      return `
        <div class="kfv-item">
          <div class="kfv-main">
            <div class="kfv-name" title="${escapeHtml(node.name)}">${escapeHtml(node.name)}</div>
            <div class="kfv-price">${formatMoney(remainDisplay, state.currency)}</div>
          </div>
          <div class="kfv-sub">
            <span>${monthlyText}</span>
            <span>周期: ${cycleText}</span>
            <span>剩余: ${remainDays.toFixed(1)}天</span>
            ${badges}
          </div>
        </div>
      `;
    }).join('') || '<div style="padding:14px 0;color:#888">暂无匹配数据</div>';
  }

  async function refreshAll() {
    state.loading = true;
    renderFinance();
    await fetchExchangeRates();
    await fetchNodes();
    state.loading = false;
    renderFinance();
  }

  async function boot() {
    ensureDOM();
    renderFinance();

    state.visitor = await fetchVisitor();
    renderVisitor();
    if (CONFIG.visitorAutoShow) openVisitor();

    await refreshAll();
    setInterval(fetchExchangeRates, CONFIG.refreshInterval);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
})();
</script>

```
