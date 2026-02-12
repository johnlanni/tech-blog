# OpenClaw 接入 Higress：解锁 GLM-5 等最新模型，告别版本升级之苦

最近 AI 圈最大的新闻，莫过于智谱发布的 GLM-5。阮一峰老师在评测中给出了相当高的评价：

> "2026年编程大模型正在从'能写代码'进阶为'能构建系统'，而 GLM-5 堪称开源界的'系统架构师'模型，从关注'前端审美'转向关注'Agentic深度/系统工程能力'，是 Opus 4.6 与 GPT-5.3 的国产开源平替。"

作为 OpenClaw 用户，我迫不及待想体验这个新模型。然而现实却给我泼了一盆冷水。

## OpenClaw 的"模型支持困境"

我在 OpenClaw 中尝试使用 `zai/glm-5`，结果报错：

```
Error: Unknown model: zai/glm-5
```

查阅后发现，OpenClaw 的智谱 provider 默认模型是硬编码的 `glm-4.7`。社区已经有人提了 [issue #14352](https://github.com/openclaw/openclaw/issues/14352)，但维护者忙于应对各种 issue 和 PR，迟迟没有支持。

这其实暴露了 OpenClaw 的一个设计问题：**新模型出来后，无法通过配置支持，必须等官方发版升级**。

看看 issue 里的吐槽：

> "OpenClaw's zai provider likely has a hardcoded model list or mapping table that doesn't include GLM-5."

这就是痛点所在——每次有新模型发布，都要等 OpenClaw 发版。而 AI 模型的迭代速度，大家都懂的，基本上是一周一更，甚至更快。

## Higress：用 AI 网关解决模型接入难题

对比之下，Higress 的设计思路完全不同：**模型配置与网关解耦，新增模型无需升级，热更新即时生效**。

### 核心优势

1. **热更新支持**：新增模型/供应商后，配置热加载，无需重启网关
2. **任意模型支持**：只要是 OpenAI 兼容 API，就能接入
3. **预配置常用模型**：插件内置了 Kimi-K2.5、Minimax-M2.1 等热门模型

### 快速接入 GLM-5

通过 Higress 的 OpenClaw Integration Skill，整个接入过程只需要几步：

```bash
# 1. 下载部署脚本
curl -fsSL https://raw.githubusercontent.com/higress-group/higress-standalone/main/all-in-one/get-ai-gateway.sh -o get-ai-gateway.sh
chmod +x get-ai-gateway.sh

# 2. 部署 Higress AI Gateway（配置智谱 + 自动路由）
./get-ai-gateway.sh start --non-interactive \
  --zhipuai-key <your-api-key> \
  --auto-routing \
  --auto-routing-default-model glm-5
```

部署完成后，安装 OpenClaw 插件：

```bash
# 启用插件
openclaw plugins enable higress

# 配置 provider（交互式）
openclaw models auth login --provider higress --set-default

# 重启 OpenClaw
openclaw gateway restart
```

现在你就可以在 OpenClaw 中使用 GLM-5 了：

```bash
# 直接指定模型
model: "higress/glm-5"

# 或者使用自动路由
model: "higress/auto"  # 会根据消息内容自动选择合适的模型
```

## 最爽的是：后续新增模型，无需重启

假设明天 DeepSeek 又发了新模型，或者 OpenAI 推出了 GPT-5.4，用 Higress 的方式是这样的：

```bash
# 直接添加新供应商的 API Key
./get-ai-gateway.sh config add --provider deepseek --key <new-key>

# 或者更新现有供应商的模型列表
# 配置热加载，立即生效！
```

**不需要重启 OpenClaw Gateway，不需要升级任何组件。**

甚至可以直接在 IM 工具中对话进行配置变更：

> 用户："帮我把默认模型切换到 glm-5"
> 
> Higress Skill："已更新，配置已热加载生效"

这就是 Higress 作为 AI 网关的核心价值：**把模型接入变成配置问题，而不是开发问题**。

## 自动路由：让 AI 自己选择最合适的模型

Higress 还支持自动路由功能，根据消息内容智能选择模型：

```bash
# 配置路由规则
./get-ai-gateway.sh route add --model glm-5 --trigger "深入思考|复杂问题|架构设计"
./get-ai-gateway.sh route add --model glm-4-flash --trigger "简单|快速|翻译"
```

使用时只需要指定 `higress/auto`：

```bash
curl 'http://localhost:8080/v1/chat/completions' \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "higress/auto",
    "messages": [{"role": "user", "content": "深入思考 如何设计一个高并发系统？"}]
  }'
```

系统会自动路由到 glm-5 进行深度推理。

## 总结

| 对比项 | OpenClaw 原生 | OpenClaw + Higress |
|--------|--------------|-------------------|
| 新模型支持 | 需要发版升级 | 配置即支持，热更新 |
| 模型切换 | 修改配置重启 | IM 对话直接切换 |
| 供应商管理 | 硬编码 | 配置驱动，灵活扩展 |
| 维护成本 | 等官方更新 | 自主可控，即时响应 |

AI 模型迭代如此之快，把模型接入变成一个"发版问题"是不合理的。Higress 的设计理念是：**让 AI 应用的架构，跟上 AI 模型的进化速度**。

如果你也是 OpenClaw 用户，正在为模型支持问题头疼，不妨试试 [Higress OpenClaw Integration Skill](https://github.com/alibaba/higress/tree/main/.claude/skills/higress-openclaw-integration)，也许能解决你的燃眉之急。

---

*P.S. 写这篇文章的时候，OpenClaw 的 issue #14352 还是 open 状态。而通过 Higress，我已经在用 GLM-5 写代码了。*
