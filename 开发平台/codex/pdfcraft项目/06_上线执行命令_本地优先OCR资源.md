# 上线执行命令（本地优先 OCR 资源）

日期：2026-03-19
适用：Linux + Nginx/Caddy 静态部署 PDFCraft
目标：在不大改上游的前提下，提高 OCR 稳定性

## 0) 变量（先改成你的实际路径）
```bash
export SITE_ROOT="/website/pdfcraft"
```

## 1) 创建本地 OCR 资源目录
```bash
sudo mkdir -p "$SITE_ROOT/tesseract" "$SITE_ROOT/tesseract-core" "$SITE_ROOT/tessdata"
```

## 2) 下载 worker/core/lang 到本站（本地优先）
```bash
# worker
sudo curl -fL "https://cdn.jsdelivr.net/npm/tesseract.js@6.0.1/dist/worker.min.js" \
  -o "$SITE_ROOT/tesseract/worker.min.js"

# core（目录直下关键文件）
sudo curl -fL "https://cdn.jsdelivr.net/npm/tesseract.js-core@v6.0.0/tesseract-core.wasm.js" \
  -o "$SITE_ROOT/tesseract-core/tesseract-core.wasm.js"
sudo curl -fL "https://cdn.jsdelivr.net/npm/tesseract.js-core@v6.0.0/tesseract-core-simd.wasm.js" \
  -o "$SITE_ROOT/tesseract-core/tesseract-core-simd.wasm.js"
sudo curl -fL "https://cdn.jsdelivr.net/npm/tesseract.js-core@v6.0.0/tesseract-core-lstm.wasm.js" \
  -o "$SITE_ROOT/tesseract-core/tesseract-core-lstm.wasm.js"
sudo curl -fL "https://cdn.jsdelivr.net/npm/tesseract.js-core@v6.0.0/tesseract-core-simd-lstm.wasm.js" \
  -o "$SITE_ROOT/tesseract-core/tesseract-core-simd-lstm.wasm.js"

# lang（至少英语+简中）
sudo curl -fL "https://tessdata.projectnaptha.com/4.0.0/eng.traineddata.gz" \
  -o "$SITE_ROOT/tessdata/eng.traineddata.gz"
sudo curl -fL "https://tessdata.projectnaptha.com/4.0.0/chi_sim.traineddata.gz" \
  -o "$SITE_ROOT/tessdata/chi_sim.traineddata.gz"
```

## 3) 权限
```bash
sudo chown -R root:root "$SITE_ROOT/tesseract" "$SITE_ROOT/tesseract-core" "$SITE_ROOT/tessdata"
sudo find "$SITE_ROOT/tesseract" "$SITE_ROOT/tesseract-core" "$SITE_ROOT/tessdata" -type f -exec chmod 644 {} \;
```

## 4) 服务端快速校验（必须都 200）
```bash
curl -I https://pdf.lottery.eu.org/tesseract/worker.min.js
curl -I https://pdf.lottery.eu.org/tesseract-core/tesseract-core-simd-lstm.wasm.js
curl -I https://pdf.lottery.eu.org/tessdata/chi_sim.traineddata.gz
```

## 5) 前端代码最小接入（仅 1 处）
文件：`src/lib/pdf/processors/ocr.ts`

把 `initializeTesseract` 设为本地优先，并保留 CDN 回退（示例见 `05_最小代码补丁_可复制执行.md`）。

## 6) 构建与发布
```bash
npm ci
npm run build
# 按你当前部署方式发布 dist/out 到站点目录
```

## 7) 验收测试（5次连续）
1. 打开 `https://pdf.lottery.eu.org/zh/tools/ocr-pdf/`
2. 选择 `Chinese (Simplified)`
3. 页码先输入 `1`
4. 使用同一个历史失败样本重复测 5 次
5. DevTools Network 确认语言包来自本站 `/tessdata/*`

通过标准：连续 5 次成功，且无 `Failed to perform OCR on PDF.`

## 8) 回滚（1分钟）
- 保留静态资源目录不动
- 把 `initializeTesseract` 改回默认初始化方式
- 重新构建发布
