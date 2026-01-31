# Reddit Post: r/kubernetes

## Title Options (pick one):

**Option A (Urgent angle):**
> Kubernetes is retiring Ingress Nginx in March 2026 - Here's how I migrated 60+ Ingress resources in 30 minutes using AI

**Option B (Practical angle):**
> Migrated from Ingress Nginx to Higress in 30 min with AI assistance - here's my experience

**Option C (Discussion angle):**
> With Ingress Nginx retiring in March, what's your migration plan? I tried AI-assisted migration to Higress

---

## Post Body:

Hey r/kubernetes,

Like many of you, I got the wake-up call from the Kubernetes Steering Committee and Security Response Committee:

> **Ingress NGINX will be retired in March 2026.**
> 
> Choosing to remain with Ingress NGINX after its retirement leaves you and your users vulnerable to attack. None of the available alternatives are direct drop-in replacements. Migration takes time and engineering resources. **About half of cloud native environments will be affected. You have two months left to prepare.**
> 
> Official statement: https://kubernetes.io/blog/2026/01/29/ingress-nginx-statement/

We have 60+ Ingress resources in production, some with custom Lua snippets. I was mentally preparing for a week of painful migration work.

Then I tried something different: **AI-assisted migration using Clawdbot with Higress community's migration skill.**

## Why Higress?

With Ingress Nginx retiring, there are several alternatives: Traefik, Kong, Envoy Gateway, Higress, etc.

For reference, I looked at **Sealos's migration** - they switched in 2023 with **2000+ tenants in ultra-high concurrency scenarios**. Their detailed writeup helped validate Higress stability at scale: [Sealos: Why We Switched from Nginx to Envoy/Higress (2000 Tenants in Production)](https://sealos.io/blog/sealos-envoy-vs-nginx-2000-tenants)

Knowing it's been battle-tested at that scale gave me confidence for our much smaller deployment.

## The Setup

Configured Clawdbot with two skills from the Higress repo:
- `nginx-to-higress-migration` - handles compatibility analysis, Kind simulation, test generation
- `higress-wasm-go-plugin` - auto-generates WASM plugins when needed

Skills location: https://github.com/alibaba/higress/tree/main/.claude/skills

## Key Insight: AI Does NOT Touch Production

This is crucial. The workflow is:

1. **AI analyzes** your current Ingress configs
2. **AI sets up Kind cluster** with your configs (sanitized)
3. **AI validates** compatibility, generates tests
4. **AI outputs** a detailed runbook with test evidence
5. **Human executes** in production

The runbook isn't AI hallucination - every recommendation is backed by actual test results in the simulation environment.

## What Happened

**60 out of 63 Ingress resources** worked immediately - Higress natively supports `nginx.ingress.kubernetes.io/*` annotations, so no YAML changes needed.

**3 Ingress resources** used `configuration-snippet` with custom Lua. Here's where it got interesting:

- 2 were replaced by Higress built-in plugins (`ip-restriction`, `basic-auth`)
- 1 required a custom WASM plugin (HMAC signature validation)

For the WASM plugin, the AI **automatically** detected the incompatibility, analyzed the Lua code, generated Go code, compiled it to WASM, pushed to our Harbor registry, and deployed to Kind for testing. **Total time: ~3 minutes. Zero manual coding.**

## Production Execution

Monday morning with the generated runbook:
- 09:00 - Install Higress (parallel with nginx)
- 09:10 - Update 3 Ingress resources
- 09:20 - Validate all routes
- 09:25 - DNS switch
- 09:30 - Monitoring looks good

**Zero alerts. Zero rollback.**

## My Takeaways

1. **Kind simulation is your safety net** - Let AI experiment there, not in prod
2. **AI generates, human executes** - Clear separation of concerns
3. **Evidence-based runbooks** - Not AI hallucination, but test-backed documentation
4. **The WASM plugin automation is insane** - What would take a week manually took 3 minutes

## The Elephant in the Room

Two months sounds like a lot, but between impact assessment, planning, resource allocation, staged rollout, and stabilization monitoring... it's really not.

If you're still on Ingress Nginx, the clock is ticking.

---

**Links:**
- Migration skill: https://github.com/alibaba/higress/tree/main/.claude/skills/nginx-to-higress-migration
- Higress docs: https://higress.io/
- My detailed blog post (Chinese): [link to GitHub]

---

**Questions for discussion:**
- What's your Ingress Nginx migration plan?
- Anyone else tried AI-assisted infrastructure migration?
- What's your experience with Higress or other alternatives (Traefik, Kong, etc.)?
