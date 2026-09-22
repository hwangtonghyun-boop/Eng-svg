---
name: free-llm-apis
description: Guide users through obtaining and configuring free API keys for LLM providers. Use when the user wants to set up a free LLM API, get a free API key, connect to a free model provider, configure an OpenAI-compatible endpoint at no cost, or asks about free tiers for AI models. Triggers on "free API key", "free LLM", "set up Gemini/Groq/Mistral/etc.", "which free provider", "how to get an API key", "free model access", "configure LLM for free", "OmniRoute", "LLM gateway", "Claude usage limit", "out of Claude credits", "continue Claude Code on free models", "무료 API 키", "무료 LLM", "크레딧 소진", "한도 초과".
---

# Free LLM API Setup

Help users pick a free LLM provider and configure their API key. Every provider here has a permanent free tier with no credit card needed. Trial credits and time-limited promos are not included.

Data synced from the [awesome-free-llm-apis README](https://github.com/mnfst/awesome-free-llm-apis) as of 2026-08-21. Free tiers change often: if a limit or model matters, tell the user to confirm it on the provider's page.

## Provider Selection

Ask the user what matters most, then recommend accordingly:

| Priority | Best picks |
|---|---|
| Best all-round single key | Google Gemini (1M context, multimodal, 1,500 RPD on Flash) |
| Highest daily request volume | NVIDIA NIM (40 RPM, 10,000 RPD), Groq (30 RPM, 1,000 RPD) |
| Fastest inference | Groq (LPU hardware) |
| Largest model selection | NVIDIA NIM (100+ models), Cloudflare Workers AI (75+ models), Hugging Face (thousands, credit-metered) |
| Many models behind one key | OpenRouter (17 `:free` models), Kilo Code (free pool + auto-router) |
| Largest token budget | Mistral AI ($10/month credits, 500K TPM) |
| Coding models | Mistral Codestral, Kilo Code / OpenRouter (`poolside/laguna-*`, `cohere/north-mini-code`) |
| European hosting | Mistral AI (FR), OVHcloud AI Endpoints (FR, EU data centers) |
| No signup or key at all | OVHcloud (2 RPM anonymous), LLM7.io (anonymous `turbo` models), Kilo Code (200 req/hr per IP) |
| Roleplay / storytelling | Aion Labs |
| One local endpoint that pools many free tiers with auto-fallback | OmniRoute (self-hosted gateway) |

Steer away from these unless the user asks for them specifically:
- **Cohere**: non-commercial use only, 1,000 calls/month.
- **SiliconFlow, ModelScope**: need Chinese real-name verification (ModelScope also needs Alibaba Cloud binding).
- **Hugging Face**: only $0.10/month of credits.

### Provider categories

**Provider APIs**: run by the companies that train the models.
- Aion Labs, Cohere, Google Gemini, Mistral AI, Z AI (Zhipu)
- See [references/provider-apis.md](references/provider-apis.md) for setup instructions.

**Inference providers**: third-party platforms hosting open-weight models.
- Cloudflare Workers AI, Groq, Hugging Face, Kilo Code, LLM7.io, ModelScope, NVIDIA NIM, Ollama Cloud, OpenRouter, OVHcloud AI Endpoints, SiliconFlow
- See [references/inference-providers.md](references/inference-providers.md) for setup instructions.

**Self-hosted gateways**: run on the user's machine and route to the providers above through one endpoint. Not part of the upstream awesome list.
- OmniRoute
- See [references/gateways.md](references/gateways.md) for setup instructions.

## Claude Usage Ran Out

If the user wants to keep a Claude Code task going on free models after hitting a Claude usage limit or running out of credits, load [references/claude-code-fallback.md](references/claude-code-fallback.md). It points the local Claude Code CLI at OmniRoute backed by official free keys, then switches back once the limit resets. Say up front that it only works for the local CLI, not cloud sessions, and that free models are weaker agents.

## Workflow

1. Ask what models, rate limits, or features the user cares about. If they already know which provider they want, skip to step 3.
2. Match their priorities against the table above. Suggest 1-2 options with a short reason.
3. Load the right reference file and walk through the setup steps for that provider (API key, code example, env var).
4. Offer a quick test script or curl command so they can confirm the key works.

## Quick Test Template

After setup, use this to verify any provider:

```python
import os
from openai import OpenAI

client = OpenAI(api_key=os.environ["API_KEY"], base_url="BASE_URL")

response = client.chat.completions.create(
    model="MODEL_NAME",
    messages=[{"role": "user", "content": "Say hello in one sentence."}],
    max_tokens=50
)
print(response.choices[0].message.content)
```

Replace BASE_URL and MODEL_NAME with values from the provider's setup guide.

## Key Notes

- All endpoints work with the OpenAI SDK unless noted.
- RPM = requests per minute, RPD = requests per day, TPM/TPD = tokens per minute/day, RPS = requests per second.
- Privacy: Google Gemini (outside EEA/UK/CH), Mistral free mode, OpenRouter free providers, Kilo Code and NVIDIA free endpoints may log or train on prompts. Warn users not to send confidential data.
- Google Gemini's free tier is available in the EEA, UK and Switzerland too, but the terms require Paid Services when serving end users in those regions.
- Groq shut down `llama-3.3-70b-versatile` and `llama-3.1-8b-instant` on 2026-08-16. Don't suggest them.
- Don't hardcode API keys. Use environment variables or a secrets manager.
