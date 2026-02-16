## Problem

OpenClaw currently has a hardcoded model list for each provider. When new models are released (like Qwen3.5, GLM-5, MiniMax M2.5), users must wait for an official release to use them.

For example:
- Setting `model: higress/qwen3.5-plus` results in `Error: Unknown model`
- Setting `model: zai/glm-5` or `model: minimax/minimax-m25` also fails
- The default models are hardcoded

With models releasing at a rapid pace (Qwen3.5 just launched with industry-leading性价比, MiniMax shipped M2, M2.1, M2.5 in just 108 days), waiting for official support is impractical.

## Solution

I've created a Higress Integration Skill that allows OpenClaw users to access any new model immediately through Higress AI Gateway, without waiting for OpenClaw updates.

**Key Benefits:**
- **Instant model support**: Any OpenAI-compatible API can be integrated immediately
- **Hot reload**: Add/update models without restarting OpenClaw gateway
- **Conversation-based config**: Just talk to OpenClaw to add models
- **Fastest model switching**: OpenClaw can switch to new models like Qwen3.5 in minutes, not days

**Why Qwen3.5?**
- **Best price-performance ratio**: Qwen3.5 offers GPT-4 level performance at a fraction of the cost
- **Strong Chinese language support**: Optimized for Chinese contexts and workflows
- **Latest capabilities**: Launched Feb 2026 with cutting-edge reasoning and coding abilities
- **Higress native integration**: Seamlessly routed through Higress gateway

## Quick Start

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

After configuration, you can use Qwen3.5, GLM-5, or MiniMax M2.5 immediately:

```yaml
# Use Qwen3.5 (Best value!)
model: "higress/qwen3.5-plus"

# Or GLM-5
model: "higress/glm-5"

# Or MiniMax M2.5
model: "higress/minimax-m25"

# Or auto-routing (smart model selection)
model: "higress/auto"
```

## Add New Models Anytime

When a new model is released, just say:

```
Please add MiniMax API Key: sk-xxx
```

Or:

```
Please add DeepSeek API Key: sk-xxx
```

No restart needed. No version upgrade needed. Hot reload takes effect immediately.

## Supported Providers

| Provider | Models |
|----------|--------|
| **Qwen (Alibaba)** | **qwen3.5-plus, qwen3.5-turbo** (Best value!) |
| z.ai | glm-4.5, glm-4-air |
| MiniMax | minimax-m2.5, minimax-m2.5-lite |
| DeepSeek | deepseek-* |
| Moonshot | moonshot-*, kimi-* |
| OpenAI | gpt-*, o1-*, o3-* |
| Anthropic | claude-* |
| Google | gemini-* |
| OpenRouter | All models |
| ...and more | |

## Why This Matters

AI models are evolving rapidly. Users shouldn't have to wait for software releases to access new models. Higress decouples model configuration from the gateway, enabling instant support for any new model.

**Qwen3.5 Highlight:**
- Launched Feb 2026 with best-in-class price-performance ratio
- OpenClaw + Higress integration enables same-day support
- Switch models in minutes via simple conversation

This is especially valuable for:
- Early adopters wanting to try the latest models (Qwen3.5, GLM-5, MiniMax M2.5, etc.)
- Teams needing specific model versions for production
- Users in regions where certain providers are unavailable
- Cost-conscious users who want optimal price-performance (Qwen3.5 delivers GPT-4 quality at ~1/10 the cost)

## Resources

- **Skill Repository**: https://github.com/alibaba/higress/tree/main/.claude/skills/higress-openclaw-integration

## Feedback

Hope this helps the community! 

I check Higress issues daily with my OpenClaw bot to resolve user problems promptly. If you encounter any issues, please feel free to create an issue at https://github.com/alibaba/higress/issues

---

## 问题

OpenClaw 目前对每个供应商都有硬编码的模型列表。当新模型发布时（如 Qwen3.5、GLM-5、MiniMax M2.5），用户必须等待官方发版才能使用。

例如：
- 设置 `model: higress/qwen3.5-plus` 会报错 `Error: Unknown model`
- 设置 `model: zai/glm-5` 或 `model: minimax/minimax-m25` 同样会失败
- 默认模型都是硬编码的

以现在的模型发布速度（Qwen3.5 刚发布就展现出业界领先的性价比，MiniMax 在 108 天内连发 M2、M2.1、M2.5 三个版本），等待官方支持根本不现实。

## 解决方案

我创建了一个 Higress Integration Skill，让 OpenClaw 用户可以通过 Higress AI Gateway 立即使用任何新模型，无需等待 OpenClaw 更新。

**核心优势：**
- **即时模型支持**：任何 OpenAI 兼容 API 都能立即接入
- **热更新**：添加/更新模型无需重启 OpenClaw 网关
- **对话式配置**：只需跟 OpenClaw 对话就能添加模型
- **最快模型切换**：OpenClaw 可以在几分钟内切换到 Qwen3.5 等新模型，而不是几天

**为什么选择 Qwen3.5？**
- **最佳性价比**：Qwen3.5 提供 GPT-4 级别性能，成本仅为一小部分
- **强大的中文支持**：针对中文场景和工作流优化
- **最新能力**：2026 年 2 月发布，具备前沿的推理和编码能力
- **Higress 原生集成**：通过 Higress 网关无缝路由

## 快速开始

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

配置完成后，你可以立即使用 Qwen3.5、GLM-5 或 MiniMax M2.5：

```yaml
# 使用 Qwen3.5（性价比最高！）
model: "higress/qwen3.5-plus"

# 或者 GLM-5
model: "higress/glm-5"

# 或者 MiniMax M2.5
model: "higress/minimax-m25"

# 或者自动路由（智能选择模型）
model: "higress/auto"
```

## 随时添加新模型

当新模型发布时，只需说：

```
帮我添加 MiniMax 的 API Key：sk-xxx
```

或者：

```
帮我添加 DeepSeek 的 API Key：sk-xxx
```

无需重启。无需版本升级。热更新立即生效。

## 支持的供应商

| 供应商 | 模型 |
|--------|------|
| **Qwen (阿里)** | **qwen3.5-plus, qwen3.5-turbo**（性价比最高！） |
| z.ai | glm-4.5, glm-4-air |
| MiniMax | minimax-m2.5, minimax-m2.5-lite |
| DeepSeek | deepseek-* |
| 月之暗面 | moonshot-*, kimi-* |
| OpenAI | gpt-*, o1-*, o3-* |
| Anthropic | claude-* |
| Google | gemini-* |
| OpenRouter | 所有模型 |
| ...更多 | |

## 为什么这很重要

AI 模型进化迅速。用户不应该为了使用新模型而等待软件发版。Higress 将模型配置与网关解耦，实现对任何新模型的即时支持。

**Qwen3.5 亮点：**
- 2026 年 2 月发布，具备业界领先的性价比
- OpenClaw + Higress 集成实现当天支持
- 通过简单对话几分钟内切换模型

这对于以下用户特别有价值：
- 想要尝试最新模型（Qwen3.5、GLM-5、MiniMax M2.5 等）的早期采用者
- 生产环境需要特定模型版本的团队
- 某些供应商不可用地区的用户
- 注重成本的用户，追求最佳性价比（Qwen3.5 以约 1/10 的成本提供 GPT-4 级别质量）

## 资源

- **Skill 仓库**: https://github.com/alibaba/higress/tree/main/.claude/skills/higress-openclaw-integration

## 反馈

希望这对社区有帮助！

我每天都会用我自己的 OpenClaw 机器人定时查看 issue，及时解决用户遇到的问题。如果你遇到任何问题，请随时在 https://github.com/alibaba/higress/issues 提 issue。
