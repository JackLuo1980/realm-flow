# next-ai-draw-io API 嵌入评估

## 结论
- 可以嵌入到其他开发系统调用。
- 仓库内已有可直接调用的 HTTP 路由，核心是 `POST /api/chat`（流式返回）。
- 但它不是“稳定对外开放 API 产品”，更像前端应用内部 API：协议来自源码，后续版本升级可能变更。

## 可用接口（基于源码）
- `POST /api/chat`：核心对话与图生成/编辑（流式 UI message stream）
- `GET /api/config`：获取 access code 与限额配置
- `GET /api/server-models`：获取服务端模型配置
- `POST /api/verify-access-code`：校验访问码（header: `x-access-code`）
- `POST /api/validate-model`：测试模型连接参数
- `POST /api/validate-diagram`：图像质量校验（VLM）
- `POST /api/parse-url`：抽取网页正文并转 markdown

## 嵌入时重点
- 鉴权：建议启用 `ACCESS_CODE_LIST`，外部系统每次请求带 `x-access-code`。
- 模型凭据：
  - 方案A（推荐）：服务端预置模型与密钥，外部系统不传密钥。
  - 方案B：外部系统动态传 header（如 `x-ai-provider` / `x-ai-api-key` / `x-ai-model`）。
- 返回类型：`/api/chat` 为流式响应，不是一次性 JSON，调用端要支持流读取。
- 稳定性：建议你在网关层封装一个“你自己的稳定 API”，不要让业务系统直接强耦合其内部字段。

## 最小调用示例（概念）
```bash
curl -N 'https://draw.lottery.eu.org/api/chat' \
  -H 'Content-Type: application/json' \
  -H 'x-access-code: <your-code>' \
  -H 'x-ai-provider: openai' \
  -H 'x-ai-model: gpt-4o' \
  -H 'x-ai-api-key: <optional-when-client-supplies-key>' \
  --data '{
    "sessionId": "ext-system-001",
    "xml": "",
    "previousXml": "",
    "messages": [
      {
        "role": "user",
        "parts": [{"type": "text", "text": "画一个支付系统时序图"}]
      }
    ]
  }'
```

## 建议落地路径
1. 先在你现有系统中接入 `/api/verify-access-code` + `/api/chat` 两个接口做 PoC。
2. 再在 Caddy 前加一层你自己的 BFF/网关，统一鉴权、限流、重试、协议适配。
3. 最后再考虑把内部字段（headers/body）映射成你自己的稳定 contract（v1/v2）。
