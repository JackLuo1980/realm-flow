# PDFCraft OCR 失败链路定位

日期：2026-03-19
目标站点：`https://pdf.lottery.eu.org/zh/`

## 现象
页面报错：`Failed to perform OCR on PDF.`

## 源码定位（上游仓库）
仓库：`https://github.com/PDFCraftTool/pdfcraft`

- 报错抛出：`src/lib/pdf/processors/ocr.ts`
- 报错显示：`src/components/tools/ocr/OCRPDFTool.tsx`

该报错是 OCR 主流程总 catch 的通用报错，不等于“识别质量差”，而是可能在以下阶段失败：
1. `loadPdfjs()`
2. `Tesseract.createWorker(...)`
3. `pdfjs.getDocument(...)`

## 结论
最常见根因是 OCR 依赖（worker/core/lang）下载链路异常，尤其是中文语言包较大，网络波动时更容易触发。
