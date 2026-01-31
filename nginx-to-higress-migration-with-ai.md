# 30分钟搞定 Nginx 到 Higress 迁移？AI 帮我干完了脏活累活

> 作者：一个不想加班的网关运维

## 起因

周五下午四点半，老板丢给我一个"小需求"：把生产环境的 ingress-nginx 迁移到 Higress。

"听说 Higress 性能更好，下周一上线吧。"

我看了眼集群里 60 多个 Ingress 资源，还有零零散散的 snippet 配置，脑子里已经开始盘算要加班几个晚上了。

直到我想起了前阵子配置的 Clawdbot，以及 Higress 社区刚发布的 nginx-to-higress-migration skill。

## 先说结论

**整个迁移过程，我实际敲键盘的时间不超过 10 分钟。** Clawdbot 在本地 Kind 集群里跑完了所有验证，最后给我输出了一份详细的操作手册。我只需要 review 一下，然后在生产环境照着执行就行。

周五晚上六点，我准时下班了。

## 为什么不让 AI 直接操作生产环境？

我知道有些同学可能会问：既然 AI 这么能干，为什么不直接让它操作生产环境？

**这个问题的答案是：因为我还想干到退休。**

生产环境是红线，任何自动化工具都不应该直接碰生产。这不是 AI 能不能的问题，是运维原则问题。

这个 skill 的设计思路非常对我胃口：**AI 在仿真环境里折腾，人在生产环境里执行**。各司其职，出了问题也能追溯。

## 实战流程

### 第一步：让 Clawdbot 了解现状

我直接在 Discord 里跟 Clawdbot 说：

```
帮我分析一下当前 K8s 集群的 ingress-nginx 配置，准备迁移到 Higress
```

Clawdbot 自动执行了这些命令：

```bash
kubectl get ingress -A -o yaml > ingress-backup.yaml
kubectl get configmap -n ingress-nginx ingress-nginx-controller -o yaml
kubectl get ingress -A -o yaml | grep "nginx.ingress.kubernetes.io" | sort | uniq -c
```

几秒钟后，它给我输出了分析报告：

- 共 63 个 Ingress 资源
- 使用了 18 种 nginx annotation
- **发现 3 个 Ingress 使用了 configuration-snippet**（这是个坑！）

关于那 3 个 snippet，Clawdbot 详细列出了它们的功能：
1. 一个是添加自定义响应头
2. 一个是简单的 IP 白名单校验
3. 一个是给某个内部服务加了 basic auth

### 第二步：Kind 仿真环境搭建

这一步是整个流程的精髓。

Clawdbot 自动用 Kind 在本地创建了一个 K8s 集群，然后：

1. 把生产环境的所有 Ingress 资源导入（脱敏后）
2. 部署了 mock 后端服务
3. 安装 Higress，配置成和生产一样的 ingressClass

```bash
# Clawdbot 执行的命令
kind create cluster --name higress-migration-test

# 安装 Higress（和 nginx 并行运行）
helm install higress higress/higress \
  -n higress-system --create-namespace \
  --set global.ingressClass=nginx \
  --set global.enableStatus=false
```

**关键配置**：`global.enableStatus=false`

这个参数很重要——它让 Higress 不去更新 Ingress 的 status 字段，避免和 nginx 打架。两个 controller 和平共处，各自处理同一批 Ingress。

### 第三步：验证迁移兼容性

Clawdbot 生成了测试脚本，覆盖所有 63 个 Ingress 的路由：

```bash
./scripts/generate-migration-test.sh > migration-test.sh
./migration-test.sh 127.0.0.1:8080
```

**60 个直接通过**，因为标准 annotation Higress 原生支持。

剩下 3 个使用 snippet 的，Clawdbot 分析后给出了解决方案：

| 原 nginx 配置 | Higress 方案 |
|--------------|-------------|
| 添加响应头 snippet | 使用 `headerControl` annotation |
| IP 白名单 | 使用内置 `ip-restriction` 插件 |
| Basic Auth | 使用内置 `basic-auth` 插件 |

**这三个都不需要写自定义 WASM 插件！** Higress 内置插件直接覆盖。

Clawdbot 自动生成了替换后的 YAML，在 Kind 环境里验证通过。

### 第四步：输出操作手册

验证全部通过后，Clawdbot 给我生成了一份操作手册：

```markdown
# Nginx to Higress 迁移操作手册

## 前置检查
- [ ] 确认已备份所有 Ingress 资源
- [ ] 确认 DNS TTL 已降低（建议 60s）
- [ ] 确认监控告警已配置

## 迁移步骤

### 1. 安装 Higress（预计 5 分钟）
（具体命令）

### 2. 修改 3 个使用 snippet 的 Ingress（预计 10 分钟）
（具体 YAML diff）

### 3. 验证 Higress 路由（预计 10 分钟）
（测试命令和预期结果）

### 4. 流量切换（预计 5 分钟）
（DNS/LB 切换步骤）

### 5. 观察监控（持续）
（关注指标清单）

## 回滚方案
（一键回滚命令）
```

## 生产环境执行

周一早上，我拿着这份手册，花了 30 分钟完成了迁移：

1. **09:00** - 安装 Higress，和 nginx 并行运行
2. **09:10** - 修改 3 个 Ingress，替换 snippet 为内置插件
3. **09:20** - 验证全部路由
4. **09:25** - 切换 DNS
5. **09:30** - 观察监控，一切正常

**全程零报警，零回滚。**

## 几点体会

### 1. 仿真环境是安全网

Kind 集群成本几乎为零，但能帮你发现 90% 的问题。让 AI 在仿真环境里折腾，比让人在生产环境里试错安全太多了。

### 2. AI 是工具，不是替代品

Clawdbot 帮我干了分析、验证、生成文档这些脏活累活，但最终执行还是我来。这种分工很合理——AI 负责提效，人负责兜底。

### 3. 好的 Skill 设计很重要

这个 nginx-to-higress-migration skill 的设计思路很清晰：
- 先分析兼容性
- 再在仿真环境验证
- 最后输出人可执行的手册

如果设计成"AI 直接帮你迁移生产环境"，我是绝对不敢用的。

### 4. 文档即代码

操作手册不是 AI 临时编的，而是根据实际验证结果生成的。哪个 Ingress 需要改、怎么改、改完什么效果，都有据可查。

## 写在最后

迁移这种事，以前要写方案、评审、排期、执行、验收，走完一套至少一周。

现在有了 AI 辅助，一天就能搞定。但**核心逻辑没变：生产环境必须由人来操作，AI 只是帮你提前验证和准备**。

如果你也在用 ingress-nginx，想迁移到 Higress，可以试试这个 skill。省下来的时间，够多打好几把游戏了。

---

## 相关链接

- [Higress nginx-to-higress-migration skill](https://github.com/alibaba/higress/tree/main/.claude/skills/nginx-to-higress-migration)
- [Higress 官方文档](https://higress.io/)
- [Clawdbot](https://github.com/clawdbot/clawdbot)
