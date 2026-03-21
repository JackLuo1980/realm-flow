const pptxgen = require("pptxgenjs");
const {
  warnIfSlideHasOverlaps,
  warnIfSlideElementsOutOfBounds,
} = require("./pptxgenjs_helpers");

const pptx = new pptxgen();
pptx.layout = "LAYOUT_WIDE";
pptx.author = "OpenAI Codex";
pptx.company = "OpenAI";
pptx.subject = "兴业银行智能贯标项目汇报";
pptx.title = "兴业银行智能贯标项目方案汇报";
pptx.lang = "zh-CN";
pptx.theme = {
  headFontFace: "Microsoft YaHei",
  bodyFontFace: "Microsoft YaHei",
  lang: "zh-CN",
};

const C = {
  navy: "153A5B",
  blue: "0B5CAB",
  blueSoft: "EAF3FC",
  ink: "102235",
  gray: "5F7285",
  line: "D7E1EA",
  white: "FFFFFF",
  greenSoft: "E8F6EE",
  goldSoft: "FFF4DD",
  bg: "F6F9FC",
};

function addSlideTitle(slide, kicker, title, subtitle) {
  slide.addText(kicker, {
    x: 0.6, y: 0.3, w: 3.5, h: 0.3, fontSize: 12, bold: true, color: C.blue,
  });
  slide.addText(title, {
    x: 0.6, y: 0.6, w: 8.5, h: 0.42, fontSize: 24, bold: true, color: C.ink,
  });
  if (subtitle) {
    slide.addText(subtitle, {
      x: 0.6, y: 1.22, w: 9.8, h: 0.25, fontSize: 10.5, color: C.gray,
    });
  }
  slide.addShape(pptx.ShapeType.line, {
    x: 0.6, y: 1.55, w: 12.0, h: 0, line: { color: C.line, pt: 1 },
  });
}

function addTag(slide, text, x, y, w = 1.6, fill = C.blueSoft, color = C.blue) {
  slide.addShape(pptx.ShapeType.roundRect, {
    x, y, w, h: 0.38, rectRadius: 0.08,
    fill: { color: fill }, line: { color: fill },
  });
  slide.addText(text, {
    x: x + 0.08, y: y + 0.08, w: w - 0.16, h: 0.2,
    fontSize: 9.5, color, bold: true, align: "center",
  });
}

function addBulletList(slide, items, x, y, w, h, fontSize = 15) {
  const runs = [];
  items.forEach((item) => {
    runs.push({
      text: item,
      options: { bullet: { indent: 14 }, breakLine: true },
    });
  });
  slide.addText(runs, {
    x, y, w, h, fontFace: "Microsoft YaHei", fontSize, color: C.ink,
    breakLine: false, paraSpaceAfterPt: 8, valign: "top",
  });
}

function addCard(slide, opts) {
  slide.addShape(pptx.ShapeType.roundRect, {
    x: opts.x, y: opts.y, w: opts.w, h: opts.h, rectRadius: 0.08,
    fill: { color: opts.fill || C.white },
    line: { color: opts.line || C.line, pt: 1.2 },
  });
  slide.addText(opts.title, {
    x: opts.x + 0.18, y: opts.y + 0.14, w: opts.w - 0.36, h: 0.24,
    fontSize: 12, bold: true, color: C.ink,
  });
  if (opts.body) {
    slide.addText(opts.body, {
      x: opts.x + 0.18, y: opts.y + 0.45, w: opts.w - 0.36, h: opts.h - 0.6,
      fontSize: 10.5, color: C.gray, valign: "top", breakLine: true,
    });
  }
}

function finalize(slide) {
  warnIfSlideHasOverlaps(slide, pptx);
  warnIfSlideElementsOutOfBounds(slide, pptx);
}

// Slide 1: Cover
{
  const slide = pptx.addSlide();
  slide.background = { color: C.bg };
  slide.addShape(pptx.ShapeType.rect, {
    x: 0, y: 0, w: 13.333, h: 7.5, fill: { color: C.bg }, line: { color: C.bg },
  });
  slide.addShape(pptx.ShapeType.roundRect, {
    x: 0.7, y: 0.75, w: 4.2, h: 5.8, rectRadius: 0.12,
    fill: { color: C.navy }, line: { color: C.navy },
  });
  slide.addText("兴业银行", {
    x: 1.0, y: 1.2, w: 2.8, h: 0.4, fontSize: 16, color: C.white, bold: true,
  });
  slide.addText("智能贯标项目", {
    x: 1.0, y: 1.85, w: 3.0, h: 0.8, fontSize: 28, color: C.white, bold: true,
  });
  slide.addText("数据字典 + 贯标智能辅助\n方案汇报", {
    x: 1.0, y: 2.9, w: 3.2, h: 1.0, fontSize: 20, color: "DCEBFA", bold: true,
  });
  slide.addText("面向全行开发人员", {
    x: 1.0, y: 4.55, w: 2.3, h: 0.35, fontSize: 12, color: C.white,
  });
  slide.addText("版本 v0.4", {
    x: 1.0, y: 5.9, w: 2.0, h: 0.3, fontSize: 10, color: "BED4EA",
  });
  slide.addText("项目定位：将智能贯标能力嵌入现有数据字典系统，建设面向开发人员的智能取数、标准推荐、重复检测、智能纠错与贯标率提升闭环。", {
    x: 5.4, y: 1.05, w: 7.1, h: 1.2, fontSize: 19, color: C.ink, bold: true,
  });
  addTag(slide, "开发人员主用", 5.45, 2.45, 1.6);
  addTag(slide, "数据字典内嵌", 7.2, 2.45, 1.65);
  addTag(slide, "私有化部署", 9.05, 2.45, 1.5);
  addTag(slide, "Java + Vue", 10.75, 2.45, 1.4);
  addCard(slide, {
    x: 5.45, y: 3.0, w: 2.15, h: 2.0,
    title: "问题",
    body: "开发人员找表、找字段、找标准成本高，接入系统的贯标率整改也缺少智能辅助。",
  });
  addCard(slide, {
    x: 7.8, y: 3.0, w: 2.15, h: 2.0,
    title: "目标",
    body: "一句话找数、自动给依据、无结果时给建标建议，并形成贯标率提升闭环。",
  });
  addCard(slide, {
    x: 10.15, y: 3.0, w: 2.15, h: 2.0,
    title: "结果",
    body: "沉淀知识库、规则库、审核闭环和整改看板，形成可量化管理成效。",
  });
  finalize(slide);
}

// Slide 2: Why / value
{
  const slide = pptx.addSlide();
  addSlideTitle(slide, "PROJECT VALUE", "为什么现在要做", "既要解决开发人员找数效率问题，也要解决接入系统贯标率提升难题");
  addCard(slide, {
    x: 0.7, y: 1.9, w: 3.9, h: 3.9, fill: C.white,
    title: "当前痛点",
    body: "1. 开发人员依赖人工问数\n2. 已有标准难复用\n3. 重复建标与命名不规范并存\n4. 数据字典尚未转化为知识库能力\n5. 接入系统贯标率整改常靠集中突击",
  });
  addCard(slide, {
    x: 4.85, y: 1.9, w: 3.9, h: 3.9, fill: C.blueSoft,
    title: "一期建设重点",
    body: "1. 数据字典内嵌入口\n2. 智能取数\n3. 标准推荐与判重\n4. 智能纠错\n5. 贯标率分析与整改辅助",
  });
  addCard(slide, {
    x: 9.0, y: 1.9, w: 3.6, h: 3.9, fill: C.greenSoft,
    title: "预期成效",
    body: "智能取数命中率 >= 70%\n定位时长下降 >= 40%\n标准推荐采纳率 >= 45%\n系统平均贯标率提升 >= 15%",
  });
  finalize(slide);
}

// Slide 3: users and scenarios
{
  const slide = pptx.addSlide();
  addSlideTitle(slide, "USERS & SCENES", "主要用户与使用场景", "主用户是全行开发人员，管理层关注贯标率、整改闭环和推广成效");
  addCard(slide, {
    x: 0.7, y: 1.9, w: 4.1, h: 3.8,
    title: "主要用户",
    body: "全行开发人员：自然语言查表、查字段、查标准\n标准管理员：推荐、判重、纠错、审核回写\n科技管理人员：看指标、看成效、看覆盖率",
  });
  addCard(slide, {
    x: 5.0, y: 1.9, w: 3.5, h: 3.8, fill: C.blueSoft,
    title: "核心场景",
    body: "1. 智能取数\n2. 标准推荐\n3. 重复检测\n4. 智能纠错\n5. 低贯标率系统整改辅助",
  });
  addCard(slide, {
    x: 8.75, y: 1.9, w: 3.85, h: 3.8, fill: C.goldSoft,
    title: "典型闭环",
    body: "进入数据字典 -> 检索字典/标准/术语 -> 返回结果或补标建议 -> 审核回写 -> 更新贯标率和整改进度",
  });
  finalize(slide);
}

// Slide 4: architecture
{
  const slide = pptx.addSlide();
  addSlideTitle(slide, "ARCHITECTURE", "总体技术架构", "数据字典前台内嵌 + Java 智能服务中心 + 模型网关 + 知识库 + 贯标率看板");
  addCard(slide, { x: 0.7, y: 1.95, w: 2.2, h: 1.1, title: "字典前台", body: "Vue 页面\n智能页签/侧栏" });
  addCard(slide, { x: 3.15, y: 1.95, w: 2.2, h: 1.1, title: "应用层", body: "Java/Spring Boot\n查询、推荐、纠错、审核" });
  addCard(slide, { x: 5.6, y: 1.95, w: 2.2, h: 1.1, title: "能力层", body: "规则引擎\n检索召回\n模型编排" });
  addCard(slide, { x: 8.05, y: 1.95, w: 2.2, h: 1.1, title: "分析层", body: "贯标率分析\n整改任务生成" });
  addCard(slide, { x: 10.5, y: 1.95, w: 2.2, h: 1.1, title: "底座层", body: "openGauss\nTDSQL\n后续 GaussDB" });
  [2.9,5.35,7.8,10.25].forEach((x) => {
    slide.addShape(pptx.ShapeType.chevron, {
      x, y: 2.28, w: 0.22, h: 0.35, fill: { color: C.blue }, line: { color: C.blue },
    });
  });
  addCard(slide, {
    x: 0.9, y: 3.45, w: 3.7, h: 2.2, fill: C.blueSoft,
    title: "模型网关",
    body: "统一接入 Qwen3、DeepSeek3\n支持路由、限流、日志、审计与置信度控制",
  });
  addCard(slide, {
    x: 4.85, y: 3.45, w: 3.7, h: 2.2, fill: C.white,
    title: "数据接入适配",
    body: "现有数据字典系统 API/库表接入\n现有贯标单体系统适配改造\n制度文档与案例入库",
  });
  addCard(slide, {
    x: 8.8, y: 3.45, w: 3.55, h: 2.2, fill: C.greenSoft,
    title: "贯标率闭环",
    body: "识别未贯标对象\nAI生成补标建议\n审核回写结果\n持续更新整改进度",
  });
  finalize(slide);
}

// Slide 5: knowledge base options
{
  const slide = pptx.addSlide();
  addSlideTitle(slide, "KNOWLEDGE BASE", "知识库路线建议", "推荐一期快速落地与长期可控两条路线并行考虑");
  addCard(slide, {
    x: 0.7, y: 1.9, w: 5.8, h: 3.9, fill: C.white,
    title: "路线一：RAGFlow + Java 自研业务层",
    body: "适合一期快速落地\n优点：文档解析、切片、索引能力较完整\n定位：承担知识处理层，不直接承载核心审核流程\n风险：需要额外补足认证、权限、审计集成",
  });
  addCard(slide, {
    x: 6.8, y: 1.9, w: 5.8, h: 3.9, fill: C.blueSoft,
    title: "路线二：Spring AI + Java 自研知识服务",
    body: "适合长期可控建设\n优点：更适合融入现有 Java 单体与行内体系\n定位：承载标准库、术语库、规则库、反馈闭环\n风险：前期设计与开发投入更高",
  });
  finalize(slide);
}

// Slide 6: rate improvement loop
{
  const slide = pptx.addSlide();
  addSlideTitle(slide, "RATE IMPROVEMENT", "贯标率提升闭环", "把系统级贯标率考核从事后突击补标，转成日常监测 + AI辅助整改");
  addCard(slide, {
    x: 0.7, y: 1.9, w: 3.7, h: 4.2,
    title: "输入",
    body: "接入系统表、字段、数据项及既有标准映射关系进入数据字典，系统按日或按周计算贯标率。",
  });
  addCard(slide, {
    x: 4.8, y: 1.9, w: 3.7, h: 4.2,
    title: "AI辅助",
    body: "针对未贯标对象执行规则校验、相似召回、候选标准推荐，并按可直接补标、需人工确认、需新建标准分类。",
  });
  addCard(slide, {
    x: 8.9, y: 1.9, w: 3.75, h: 4.2,
    title: "输出",
    body: "生成整改任务、审核回写数据字典与贯标系统，并在看板中持续展示系统贯标率、低贯标率排行和整改闭环率。",
  });
  finalize(slide);
}

// Slide 7: prototype snapshots
{
  const slide = pptx.addSlide();
  addSlideTitle(slide, "PROTOTYPE", "页面原型展示", "数据字典内嵌式智能贯标页面，兼顾最终用户操作与领导汇报");
  addCard(slide, {
    x: 0.7, y: 1.9, w: 4.0, h: 4.2,
    title: "数据字典内嵌智能取数页",
    body: "核心搜索区 + 快捷查询 + 推荐结果卡片 + 无结果建标建议\n目标：一句话找到数据、字段和标准",
  });
  addCard(slide, {
    x: 4.95, y: 1.9, w: 4.0, h: 4.2,
    title: "结果详情与整改承接页",
    body: "展示系统、库、表、字段、标准、依据与操作按钮\n目标：让开发人员和标准管理员快速判断能否直接使用或补标",
  });
  addCard(slide, {
    x: 9.2, y: 1.9, w: 3.45, h: 4.2,
    title: "领导看板页",
    body: "展示命中率、采纳率、系统平均贯标率、低贯标率系统排行等关键指标\n目标：支持管理层汇报与推广决策",
  });
  finalize(slide);
}

// Slide 8: delivery & team
{
  const slide = pptx.addSlide();
  addSlideTitle(slide, "DELIVERY", "实施计划与团队建议", "按 4-5 个月交付节奏设计，一期工作量约 50-72 人周");
  addCard(slide, {
    x: 0.7, y: 1.95, w: 4.3, h: 4.1, fill: C.white,
    title: "里程碑",
    body: "M1 方案冻结（2-4周）\nM2 知识库底座可用（6-10周）\nM3 核心能力联调完成（10-16周）\nM4 试点验收（16-20周）",
  });
  addCard(slide, {
    x: 5.2, y: 1.95, w: 3.6, h: 4.1, fill: C.blueSoft,
    title: "推荐团队",
    body: "项目/交付 1\n产品/方案 1\n后端 2-3\n前端 1-2\nAI 1\n数据/知识 1\n测试 1\n架构/DBA 0.5-1",
  });
  addCard(slide, {
    x: 9.0, y: 1.95, w: 3.65, h: 4.1, fill: C.greenSoft,
    title: "关键前提",
    body: "客户已提供 Qwen3、DeepSeek3 私有化能力\n数据字典可 API/库表接入\n现有单体系统可配合适配改造",
  });
  finalize(slide);
}

// Slide 9: conclusion
{
  const slide = pptx.addSlide();
  slide.background = { color: C.navy };
  slide.addText("建议结论", {
    x: 0.8, y: 0.9, w: 2.5, h: 0.4, fontSize: 16, color: "BBD6F0", bold: true,
  });
  slide.addText("先把开发人员高频使用的\n智能取数与贯标辅助能力做实", {
    x: 0.8, y: 1.45, w: 6.4, h: 1.5, fontSize: 28, color: C.white, bold: true,
  });
  slide.addText("建设路径建议：数据字典内嵌、知识库先行、规则约束、模型增强、人机协同、私有化部署、信创兼容。", {
    x: 0.8, y: 3.15, w: 7.9, h: 0.45, fontSize: 15, color: "DCEBFA",
  });
  addCard(slide, {
    x: 8.9, y: 1.2, w: 3.6, h: 1.4, fill: "244C71", line: "244C71",
    title: "价值导向",
    body: "让开发人员更快找到可用数据\n让管理层看到贯标率与整改成效",
  });
  addCard(slide, {
    x: 8.9, y: 3.05, w: 3.6, h: 1.4, fill: "244C71", line: "244C71",
    title: "交付导向",
    body: "4-5个月完成一期闭环\n50-72人周可控推进",
  });
  addCard(slide, {
    x: 8.9, y: 4.9, w: 3.6, h: 1.2, fill: "244C71", line: "244C71",
    title: "演进导向",
    body: "为后续更多标准化能力扩展打基础",
  });
  finalize(slide);
}

async function main() {
  await pptx.writeFile({ fileName: "/Users/jack/Documents/Playground/xingye-smart-gb-prototype/ppt/兴业银行智能贯标项目汇报_v0.4.pptx" });
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
