# Use Higress to Access GLM-5 and Other Latest Models Without Waiting for OpenClaw Updates | 使用 Higress 接入 GLM-5 等最新模型，无需等待 OpenClaw 发版

## English Version

### Problem

OpenClaw currently has a hardcoded model list for each provider. When a new model is released (like GLM-5), users must wait for an official release to use it.

Example from [issue #14352](https://github.com/openclaw/openclaw/issues/14352):
- Setting `model: zai/glm-5` results in `Error: Unknown model: zai/glm-5`
- The default model is hardcoded as `glm-4.7`

### Solution

I've created a Higress Integration Skill that allows OpenClaw users to access any new model immediately through Higress AI Gateway, without waiting for OpenClaw updates.

**Key Benefits:**
- **Instant model support**: Any OpenAI-compatible API can be integrated immediately
- **Hot reload**: Add/update models without restarting OpenClaw gateway
- **Conversation-based config**: Just talk to OpenClaw to add models

### Quick Start

Just send this message to OpenClaw:

```
Please install this skill and use it to configure Higress:
https://github.com/alibaba/higress/tree/main/.claude/skills/higress-openclaw-integration
```

OpenClaw will automatically:
1. Install the Higress Integration Skill
2. Deploy Higress AI Gateway
3. Configure your specified model providers
4. Enable the Higress plugin

After configuration, you can use GLM-5 immediately:

```yaml
model: "higress/glm-5"
```

### Add New Models Anytime

When a new model is released, just say:

```
Please add DeepSeek API Key: sk-xxx
```

No restart needed. No version upgrade needed. Hot reload takes effect immediately.

### Supported Providers

| Provider | Models |
|----------|--------|
| Zhipu AI | glm-* |
| DeepSeek | deepseek-* |
| Moonshot | moonshot-*, kimi-* |
| OpenAI | gpt-*, o1-*, o3-* |
| Anthropic | claude-* |
| Google | gemini-* |
| OpenRouter | All models |
| ...and more | |

### Why This Matters

AI models are evolving rapidly. Users shouldn't have to wait for software releases to access new models. Higress decouples model configuration from the gateway, enabling instant support for any new model.

This is especially valuable for:
- Early adopters wanting to try the latest models
- Teams needing specific model versions for production
- Users in regions where certain providers are unavailable

### Resources

- **Skill Repository**: https://github.com/alibaba/higress/tree/main/.claude/skills/higress-openclaw-integration

---

## 中文版本

### 问题

OpenClaw 目前对每个供应商都有硬编码的模型列表。当新模型发布时（如 GLM-5），用户必须等待官方发版才能使用。

示例来自 [issue #14352](https://github.com/openclaw/openclaw/issues/14352)：
- 设置 `model: zai/glm-5` 会报错 `Error: Unknown model: zai/glm-5`
- 默认模型被硬编码为 `glm-4.7`

### 解决方案

我创建了一个 Higress Integration Skill，让 OpenClaw 用户可以通过 Higress AI Gateway 立即使用任何新模型，无需等待 OpenClaw 更新。

**核心优势：**
- **即时模型支持**：任何 OpenAI 兼容 API 都能立即接入
- **热更新**：添加/更新模型无需重启 OpenClaw 网关
- **对话式配置**：只需跟 OpenClaw 对话就能添加模型

### 快速开始

只需向 OpenClaw 发送这条消息：

```
帮我安装下这个skill，然后使用这个skill帮我配置higress：
https://github.com/alibaba/higress/tree/main/.claude/skills/higress-openclaw-integration
```

OpenClaw 会自动：
1. 安装 Higress Integration Skill
2. 部署 Higress AI Gateway
3. 配置你指定的模型供应商
4. 启用 Higress 插件

配置完成后，你可以立即使用 GLM-5：

```yaml
model: "higress/glm-5"
```

### 随时添加新模型

当新模型发布时，只需说：

```
帮我添加 DeepSeek 的 API Key：sk-xxx
```

无需重启。无需版本升级。热更新立即生效。

### 支持的供应商

| 供应商 | 模型 |
|--------|------|
| 智谱 AI | glm-* |
| DeepSeek | deepseek-* |
| 月之暗面 | moonshot-*, kimi-* |
| OpenAI | gpt-*, o1-*, o3-* |
| Anthropic | claude-* |
| Google | gemini-* |
| OpenRouter | 所有模型 |
| ...更多 | |

### 为什么这很重要

AI 模型进化迅速。用户不应该为了使用新模型而等待软件发版。Higress 将模型配置与网关解耦，实现对任何新模型的即时支持。

这对于以下用户特别有价值：
- 想要尝试最新模型的早期采用者
- 生产环境需要特定模型版本的团队
- 某些供应商不可用地区的用户

### 资源

- **Skill 仓库**: https://github.com/alibaba/higress/tree/main/.claude/skills/higress-openclaw-integration

---

Hope this helps the community! Would love to hear feedback.

希望这对社区有帮助！欢迎反馈。
