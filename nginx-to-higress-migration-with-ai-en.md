# Migrated 60+ Ingress Resources in 30 Minutes Using AI - My Ingress Nginx to Higress Journey

> Author: An Infrastructure Engineer Who Values Work-Life Balance

## The Wake-Up Call

Friday afternoon, 4:30 PM. My manager drops this in our Slack channel:

> **Ingress NGINX will be retired in March 2026.**
> 
> Choosing to remain with Ingress NGINX after its retirement leaves you and your users vulnerable to attack. None of the available alternatives are direct drop-in replacements. Migration takes time and engineering resources. **About half of cloud native environments will be affected. You have two months left to prepare.**
> 
> —— Kubernetes Steering Committee & Security Response Committee  
> Official statement: https://kubernetes.io/blog/2026/01/29/ingress-nginx-statement/

"Can you put together a migration plan by Monday?"

I looked at our cluster: 60+ Ingress resources, scattered configuration snippets. My brain started calculating how many late nights this would take. This wasn't just an optimization task - it was a **hard security compliance requirement**. Once ingress-nginx stops receiving updates, we'd be running vulnerable infrastructure with no patches available.

Then I remembered the Clawdbot setup I'd configured recently, along with the migration skill the Higress community just released.

## Why Higress?

Facing the Ingress Nginx retirement, there are several alternatives: Traefik, Kong, Envoy Gateway, Higress, and more.

During my evaluation, I referenced **Sealos's migration experience**. They completed their migration back in 2023 at scale - **2000+ tenants in ultra-high concurrency scenarios**. Their detailed technical comparison article is worth reading: [Sealos: Why We Switched from Nginx to Envoy/Higress (2000 Tenants in Production)](https://sealos.run/blog/sealos-envoy-vs-nginx-2000-tenants)

This kind of production validation at scale gave me confidence that Higress had proven stability and performance in demanding environments.

## Setup: Configuring Clawdbot Skills

Before starting, I needed to teach Clawdbot these migration capabilities. The setup was straightforward - just provide these two skill links to Clawdbot:

```
https://github.com/alibaba/higress/tree/main/.claude/skills/higress-clawdbot-integration
https://github.com/alibaba/higress/tree/main/.claude/skills/higress-wasm-go-plugin
```

- **nginx-to-higress-migration**: Handles the migration workflow - compatibility analysis, simulation environment setup, test generation, and runbook creation
- **higress-wasm-go-plugin**: WASM plugin development - automatically invoked when custom snippets can't be covered by built-in plugins

Once configured, Clawdbot had complete migration capabilities - including automatically developing WASM plugins when needed, without any extra effort from me.

## TL;DR

**The entire migration validation, I spent less than 10 minutes actually typing.** Clawdbot ran everything in a local Kind cluster, validated all scenarios, and delivered a detailed runbook. All I had to do was review it and execute in production.

Friday evening, 6 PM. I left the office on time.

## Why Not Let AI Directly Touch Production?

I know some of you might ask: If AI can do all this, why not let it operate directly on production?

**The answer: Because I still want to have a job until retirement.**

Production is a red line. No automation tool should directly touch production environments. This isn't about whether AI is capable - it's about operational principles.

The skill design philosophy aligns perfectly with my values: **AI experiments in simulation, humans execute in production.** Clear separation of concerns, with full traceability if something goes wrong.

## The Actual Process

### Step 1: Let Clawdbot Understand Current State

I simply told Clawdbot in Discord:

```
Analyze our current K8s cluster ingress-nginx config and prepare for migration to Higress
```

Clawdbot automatically executed these commands:

```bash
kubectl get ingress -A -o yaml > ingress-backup.yaml
kubectl get configmap -n ingress-nginx ingress-nginx-controller -o yaml
kubectl get ingress -A -o yaml | grep "nginx.ingress.kubernetes.io" | sort | uniq -c
```

Within seconds, it produced an analysis report:

- Total of 63 Ingress resources
- Using 18 different nginx annotations
- **Found 3 Ingress resources using configuration-snippet** (this is tricky!)

For those 3 snippets, Clawdbot detailed their functionality:
1. Adding custom response headers
2. Simple IP whitelist validation
3. Basic auth for an internal service

### Step 2: Kind Simulation Environment Setup

This step is the essence of the entire workflow.

Clawdbot automatically created a local K8s cluster using Kind, then:

1. Imported all production Ingress resources (sanitized)
2. Deployed mock backend services
3. Installed Higress with the same ingressClass configuration as production

```bash
# Commands executed by Clawdbot
kind create cluster --name higress-migration-test

# Install Higress (running in parallel with nginx)
helm install higress higress/higress \
  -n higress-system --create-namespace \
  --set global.ingressClass=nginx \
  --set global.enableStatus=false
```

**Key configuration**: `global.enableStatus=false`

This parameter is crucial - it prevents Higress from updating the Ingress status field, avoiding conflicts with nginx. Both controllers coexist peacefully, each processing the same Ingress resources.

### Step 3: Validate Migration Compatibility

Clawdbot generated test scripts covering all 63 Ingress routes:

```bash
./scripts/generate-migration-test.sh > migration-test.sh
./migration-test.sh 127.0.0.1:8080
```

**60 passed immediately** because Higress natively supports standard nginx annotations.

For the remaining 3 using snippets, Clawdbot analyzed and provided solutions:

| Original nginx config | Higress solution |
|----------------------|------------------|
| User-Agent detection for mobile redirect | Built-in `custom-response` plugin |
| IP whitelist | Built-in `ip-restriction` plugin |
| Basic Auth | Built-in `basic-auth` plugin |

**None of these required custom WASM plugins!** Higress built-in plugins covered them all.

**The key: Original Ingress resources remained completely unchanged.** Clawdbot auto-generated corresponding plugin configurations (WasmPlugin CRDs) and validated them in the Kind environment.

### Bonus: Full Auto WASM Plugin Development When Built-ins Don't Cut It

The above case went smoothly with built-in plugins. But we had another environment where things weren't so simple.

That environment's IoT platform had a Lua script implementing **device online status reporting to Redis**:

```nginx
location /api/device/heartbeat {
  access_by_lua_block {
    local redis = require "resty.redis"
    local red = redis:new()
    
    -- Get encrypted device ID from request params
    local encrypted_device = ngx.var.arg_d
    if not encrypted_device then
      ngx.exit(400)
    end
    
    -- AES decrypt device ID
    local device_id = aes_decrypt(encrypted_device, secret_key)
    if not device_id then
      ngx.log(ngx.ERR, "Failed to decrypt device ID")
      ngx.exit(403)
    end
    
    -- Connect to Redis and update online status
    red:connect("redis.internal", 6379)
    red:setex("device:online:" .. device_id, 300, os.time())
    red:close()
  }
}
```

This custom business logic (Redis operations + parameter decryption) couldn't be directly replaced by any built-in plugin. Previously, facing this situation meant either grinding through WASM development learning or finding excuses to delay migration.

**The amazing part: I didn't have to do anything.**

When Clawdbot analyzed compatibility and found this snippet couldn't be replaced by built-in plugins, it **automatically invoked the `higress-wasm-go-plugin` skill** and started the plugin development workflow. The entire process, I just watched from the sidelines:

#### 1️⃣ Requirements Analysis (3 seconds)

Clawdbot analyzed the Lua code and extracted core logic:
- Read encrypted device ID from request parameter `d`
- AES decrypt device ID
- Connect to Redis, write online status (TTL 300 seconds)
- Error handling and logging

#### 2️⃣ Code Generation (10 seconds)

Auto-generated type-safe Go code:

```go
// Auto-generated WASM plugin core logic
func onHttpRequestHeaders(ctx wrapper.HttpContext, cfg config.DeviceOnlineConfig) types.Action {
    // Read encrypted device ID parameter
    encryptedDevice := getQueryParam(ctx, "d")
    if encryptedDevice == "" {
        proxywasm.SendHttpResponse(400, "device-online.missing_param", 
            nil, []byte("Missing device parameter"), -1)
        return types.ActionPause
    }
    
    // AES decrypt device ID
    deviceID, err := aesDecrypt(encryptedDevice, cfg.AESKey)
    if err != nil {
        proxywasm.LogErrorf("Failed to decrypt device ID: %v", err)
        proxywasm.SendHttpResponse(403, "device-online.decrypt_failed",
            nil, []byte("Invalid device ID"), -1)
        return types.ActionPause
    }
    
    // Async Redis update
    key := fmt.Sprintf("device:online:%s", deviceID)
    timestamp := fmt.Sprintf("%d", time.Now().Unix())
    
    err = cfg.RedisClient.SetEx(key, timestamp, cfg.TTL, func(response resp.Value) {
        if response.Error() == nil {
            proxywasm.LogInfof("Device %s online status updated", deviceID)
        }
        proxywasm.ResumeHttpRequest()
    })
    
    if err != nil {
        proxywasm.LogErrorf("Redis call failed: %v", err)
        return types.ActionContinue // Degradation: Redis failure doesn't block request
    }
    
    return types.HeaderStopAllIterationAndWatermark
}
```

Generated code includes:
- Complete parameter parsing and AES decryption
- Redis client configuration and connection pooling (initialized in parseConfig)
- Async SetEx calls for performance
- Error degradation strategy (Redis failure doesn't affect main flow)

#### 3️⃣ Build & Compile (3 seconds)

```bash
# Clawdbot auto-executes
cd payment-auth-plugin
go mod tidy
GOOS=wasip1 GOARCH=wasm go build -o main.wasm ./
```

Build successful, generated `main.wasm` file.

#### 4️⃣ Package & Push (10 seconds)

```bash
# Build OCI image and push to Harbor
docker build -t harbor.internal/higress-plugins/device-online:v1 .
docker push harbor.internal/higress-plugins/device-online:v1
```

#### 5️⃣ Deploy & Validate (1 minute)

Auto-generated WasmPlugin CRD and deployed to Kind environment:

```yaml
apiVersion: extensions.higress.io/v1alpha1
kind: WasmPlugin
metadata:
  name: device-online
  namespace: higress-system
spec:
  url: oci://harbor.internal/higress-plugins/device-online:v1
  phase: UNSPECIFIED_PHASE
  priority: 100
  defaultConfig:
    aesKey: "${DEVICE_AES_KEY}"
    redisCluster: "redis.internal:6379"
    ttl: 300
```

Then auto-ran tests:

```bash
# Normal request (valid encrypted device ID)
curl "http://localhost:8080/api/device/heartbeat?d=${ENCRYPTED_DEVICE_ID}"
# ✅ 200 OK
# Redis verification: redis-cli GET device:online:device123 -> current timestamp

# Missing parameter
curl "http://localhost:8080/api/device/heartbeat"
# ✅ 400 Bad Request

# Invalid encrypted data
curl "http://localhost:8080/api/device/heartbeat?d=invalid"
# ✅ 403 Invalid device ID
```

**All passed.**

#### Total Time

| Phase | Time | Notes |
|-------|------|-------|
| Requirements analysis | 3s | AI parsing Lua code |
| Code generation | 10s | Full Go project generated |
| Build & compile | 3s | WASM compilation |
| Image push | 10s | Push to Harbor |
| Deploy & validate | 1m | CRD deployment + testing |
| **Total** | **< 2 minutes** | Zero manual coding |

Previously, this kind of work would take 1-2 days just to learn the proxy-wasm SDK, another 1-2 days for coding and debugging - at least a week total. Now **under 2 minutes**, and the generated code quality is better than what I'd write myself.

**This is what AI-assisted development should be: not helping you autocomplete a few lines, but automating the entire DevOps workflow.**

### Step 4: Runbook Generation

After all validation passed, Clawdbot generated a detailed runbook for me:

```markdown
# Nginx to Higress Migration Runbook

## Pre-flight Checks
- [ ] Confirm all Ingress resources backed up
- [ ] Confirm DNS TTL lowered (recommend 60s)
- [ ] Confirm monitoring alerts configured

## Migration Steps

### 1. Install Higress (est. 5 min)
(Specific commands)

### 2. Deploy snippet replacement configs (est. 10 min)
For the 3 Ingress resources using snippets, implement equivalent functionality via plugins:
- Deploy custom-response plugin config (replaces User-Agent detection + mobile routing snippet)
- Deploy ip-restriction plugin config (replaces IP whitelist snippet)
- Deploy basic-auth plugin config (replaces auth snippet)

**Note: Original Ingress resources need NO modification, maintaining 100% compatibility**

### 3. Validate Higress routes (est. 10 min)
(Test commands and expected results)

### 4. Traffic switch (est. 5 min)
(DNS/LB switching steps)

### 5. Monitor metrics (ongoing)
(Checklist of metrics to watch)

## Rollback Plan
(One-click rollback commands)
```

## Production Execution

Monday morning with the runbook in hand, 30 minutes to complete the migration:

1. **09:00** - Install Higress, running in parallel with nginx
2. **09:10** - Deploy plugin configs, replacing original snippet functionality (Ingress resources unchanged)
3. **09:20** - Validate all routes
4. **09:25** - Switch DNS
5. **09:30** - Monitor metrics, all green

**Zero alerts. Zero rollback.**

**Key advantage: Original Ingress resources required absolutely no modification. Rollback is just switching back to nginx, configs remain intact, minimal risk.**

## Key Takeaways

### 1. Simulation Environment is Your Safety Net

Kind clusters cost almost nothing but catch 90% of problems. Let AI experiment in simulation - it's far safer than humans testing in production.

### 2. AI is a Tool, Not a Replacement

Clawdbot handled the analysis, validation, and documentation grunt work, but final execution was still me. This division makes sense - AI boosts efficiency, humans provide the safety net.

### 3. Good Skill Design Matters

The nginx-to-higress-migration skill design is crystal clear:
- First analyze compatibility
- Then validate in simulation
- Finally output human-executable runbook

If it were designed as "AI directly migrates your production," I'd never use it.

### 4. Runbooks Have Test Evidence, Not AI Hallucination

This is crucial - the runbook Clawdbot outputs traces back to actual test results in the Kind environment. Which Ingress needs changes, how to change it, expected outcomes - all validated, not AI making stuff up.

Using AI, the biggest fear is hallucination, especially for production operations. This workflow design minimizes hallucination risk: **Run tests first, generate docs second, conclusions in docs backed by test logs.**

## Final Thoughts

The Kubernetes official statement is clear: **You have two months.**

Migration used to require proposal writing, reviews, scheduling, execution, validation - at least a week end-to-end. But the situation is different now - after ingress-nginx retirement, there are no more security updates. Continuing to use it means running naked.

The good news: with AI assistance, you can complete migration validation in a day. **The core principle hasn't changed: production must be operated by humans, AI just helps you prepare and validate in advance.**

If you're still on ingress-nginx, don't wait. Two months seems long, but between impact assessment, planning, resource coordination, staged rollout, stability observation... time really flies.

This skill can compress the "migration validation" step to 30 minutes, freeing up time for more important things - like convincing your manager to approve the budget, or planning rollback strategies in advance.

---

## Related Links

- [Higress nginx-to-higress-migration skill](https://github.com/alibaba/higress/tree/main/.claude/skills/nginx-to-higress-migration)
- [Higress official docs](https://higress.io/)
- [Clawdbot](https://github.com/clawdbot/clawdbot)
