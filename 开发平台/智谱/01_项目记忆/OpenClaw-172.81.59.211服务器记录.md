# OpenClaw服务器记录

> 服务器IP: 172.81.59.211
> 密码: DH{.h;g-{9PZJ9lZTI

## 服务器基本信息

- **IP地址**: 172.81.59.211
- **密码**: DH{.h;g-{9PZJ9lZTI
- **部署时间**: 2026-03-14
- **OpenClaw版本**: 2026.3.8
- **配置目录**: /root/.openclaw/

## OpenClaw运行状态

- **状态**: 正常运行
- **部署方式**: 本地安装（非Docker容器）
- **端口**: 18789
- **配置文件**: /root/.openclaw/openclaw.json

## 模型配置（2026-03-19更新）

### 主要配置
- **主模型**: zhipuai/glm-4.7
- **备用模型**: zhipuai/glm-4-flash, zhipuai/glm-4, qtcool/gpt-5.2-codex, aipaibox/claude-opus-4-6

### 智谱AI配置
```json
{
  "zhipuai": {
    "baseUrl": "https://open.bigmodel.cn/api/paas/v4",
    "apiKey": "ac061722626e42738e7e8ab1b5187249.rFmU5JfVf0hsHdB1",
    "api": "openai-completions",
    "models": [
      {
        "id": "glm-4.7",
        "name": "GLM-4.7",
        "contextWindow": 128000,
        "reasoning": false,
        "input": ["text"]
      },
      {
        "id": "glm-4",
        "name": "GLM-4",
        "contextWindow": 128000,
        "reasoning": false,
        "input": ["text"]
      },
      {
        "id": "glm-4-flash",
        "name": "GLM-4-Flash",
        "contextWindow": 128000,
        "reasoning": false,
        "input": ["text"]
      }
    ]
  }
}
```

### 其他模型提供商

1. **aipaibox** (API Key: sk-lQ81Jc1MxqMQCmdDgLg29igsJPktAkhZ4OLXmvumiTUkoUfg)
   - gemini-3-flash
   - Claude Opus 4.6系列
   - Claude Sonnet 4.5系列

2. **qtcool** (API Key: sk-0JDu7hyc51ZKD4iNebpFu07EUEhXmVVc)
   - GPT-5.4
   - GPT-5.3 Codex
   - GPT-5.2系列

## Telegram集成

- **Bot Token**: 8322924053:AAEik4qp8ZJxCtaIMlvuWcDcKqI6u7H1Lnc
- **允许用户**: 1603970047
- **策略**: allowlist
- **DM策略**: pairing
- **流式传输**: partial

## 网关配置

- **端口**: 18789
- **模式**: local
- **绑定**: lan
- **认证方式**: token
- **认证Token**: 9dc105a2b9c2149abb10889808515c4f2f67127ae0425603
- **允许的来源**:
  - http://172.81.59.211:18789
  - tauri://localhost
  - https://tauri.localhost
  - http://localhost:1420
  - http://127.0.0.1:1420
  - http://172.81.59.211:1420

## 维护操作记录

### 2026-03-19 模型配置更新

**任务**: 将OpenClaw默认模型改为智谱AI模型

**操作步骤**:
1. 连接服务器检查OpenClaw运行状态
2. 备份原配置文件: `cp /root/.openclaw/openclaw.json /root/.openclaw/openclaw.json.backup-20260319`
3. 使用Python脚本更新配置文件
4. 添加智谱AI provider配置
5. 修改默认主模型为 `zhipuai/glm-4.7`
6. 更新备用模型列表
7. 更新main agent模型配置

**配置变更**:
- 主模型: `qtcool/gpt-5.2-codex` → `zhipuai/glm-4.7`
- 新增provider: `zhipuai`
- 新增模型: `glm-4.7`, `glm-4`, `glm-4-flash`

**注意事项**:
- 配置文件路径: `/root/.openclaw/openclaw.json`
- 配置更新后需要重启OpenClaw gateway服务

### 2026-03-19 服务重启与故障排查

**任务**: 排查Telegram消息无反馈问题

**排查过程**:
1. 检查OpenClaw运行状态：服务未运行
2. 查看日志文件：最新日志显示最后运行时间为2026-03-14
3. 检查端口18789：无服务监听
4. 启动OpenClaw服务：`nohup openclaw gateway > /dev/null 2>&1 &`
5. 验证服务状态：确认服务正常运行，端口18789已监听
6. 检查新日志：确认智谱AI模型配置已生效

**发现的问题**:
- OpenClaw配置更新后服务未重启，导致新配置未生效
- 智谱AI API密钥余额不足：`429 余额不足或无可用资源包,请充值。`
- **根本原因**: 智谱AI账户对不同模型的配额不同
  - glm-4.7: 余额不足（状态码429）
  - glm-4: 余额不足（状态码429）
  - glm-4-flash: 可正常使用（状态码200）
- Telegram Bot连接正常，但模型调用失败

**API测试结果**:
```bash
# 模型 glm-4 测试
状态码: 429
错误: {"error":{"code":"1113","message":"余额不足或无可用资源包,请充值。"}}

# 模型 glm-4-flash 测试
状态码: 200
成功! 响应: {"choices":[{"finish_reason":"stop","index":0,"message":{"content":"你好👋！很高兴见到你，有什么可以帮助你的吗？","role":"assistant"}}]
```

**解决方案**:
1. 调整备用模型优先级，将glm-4-flash放在第一位
2. 保持主模型为glm-4.7（根据用户要求）
3. 当glm-4.7余额不足时，自动fallback到glm-4-flash

**配置更新**:
- 主模型: zhipuai/glm-4.7
- 备用模型优先级: glm-4-flash → glm-4 → qtcool/gpt-5.2-codex → aipaibox/claude-opus-4-6

**服务状态确认**:
- OpenClaw进程正常运行 (PID 873572)
- Gateway端口18789正常监听
- Telegram Bot连接正常
- 主模型已切换为zhipuai/glm-4.7
- 配置热重载已生效

**后续处理**:
- 服务已恢复正常，可以处理Telegram消息
- 如glm-4.7和glm-4-flash都不可用时，会自动fallback到其他provider

## 重要文件路径

- **配置文件**: /root/.openclaw/openclaw.json
- **备份文件**: /root/.openclaw/openclaw.json.backup-*
- **日志目录**: /root/.openclaw/logs/
- **工作空间**: /root/.openclaw/workspace/
- **设备目录**: /root/.openclaw/devices/
- **代理目录**: /root/.openclaw/agents/

## SSH连接命令

```bash
sshpass -p 'DH{.h;g-{9PZJ9lZTI' ssh -o StrictHostKeyChecking=no root@172.81.59.211
```

## 管理命令

```bash
# 查看配置
cat /root/.openclaw/openclaw.json

# 检查运行状态
ps aux | grep claw

# 查看网关端口
ss -tlnp | grep 18789

# 备份配置
cp /root/.openclaw/openclaw.json /root/.openclaw/openclaw.json.backup-$(date +%Y%m%d-%H%M%S)
```

## 技术要点

### 配置文件格式
- JSON格式
- 支持多provider配置
- 模型fallback机制
- Agent个性化配置

### 安全设置
- Token认证
- 设备认证已禁用（dangerouslyDisableDeviceAuth）
- 允许不安全认证
- 用户白名单机制

---

*最后更新: 2026-03-19*