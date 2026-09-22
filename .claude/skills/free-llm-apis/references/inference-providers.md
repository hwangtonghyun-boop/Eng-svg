# Inference Providers - Setup Guides

Third-party platforms that host open-weight models from various sources.

Every provider below works with the OpenAI SDK. Unless a section shows its own code, use this pattern with the section's base URL, model and env var:

```python
import os
from openai import OpenAI

client = OpenAI(api_key=os.environ["ENV_VAR"], base_url="BASE_URL")

response = client.chat.completions.create(
    model="MODEL",
    messages=[{"role": "user", "content": "Hello!"}]
)
print(response.choices[0].message.content)
```

---

## NVIDIA NIM

**Models:** Nemotron 3 Ultra 550B / Super 120B / Nano 30B, Llama 3.3 70B, gpt-oss-120b / 20b, Gemma 4 31B, MiniMax M3, Mistral Large 2 +92 more
**Limits:** 40 RPM, 10,000 RPD per model
**Notes:** Free with NVIDIA Developer Program membership.

### Get your API key

1. Go to [NVIDIA Build](https://build.nvidia.com/explore/discover).
2. Create an NVIDIA account or sign in (joins the Developer Program).
3. Pick any model and click "Get API Key."
4. Copy the key.

- **Base URL:** `https://integrate.api.nvidia.com/v1/`
- **Model:** `meta/llama-3.3-70b-instruct` (or `openai/gpt-oss-120b`, `nvidia/nemotron-3-super-120b-a12b`)
- **Env var:** `export NVIDIA_API_KEY="your-key-here"`

---

## Groq

**Models:** `openai/gpt-oss-120b`, `openai/gpt-oss-20b`, `qwen/qwen3.6-27b`, `groq/compound`, `groq/compound-mini`
**Limits:** 30 RPM; 1,000 RPD (compound models: 250 RPD)
**Notes:** Ultra-fast LPU inference. `llama-3.3-70b-versatile` and `llama-3.1-8b-instant` were shut down on 2026-08-16.

### Get your API key

1. Go to the [Groq Console](https://console.groq.com/keys).
2. Create an account or sign in.
3. Click "Create API Key," name it and copy the key.

- **Base URL:** `https://api.groq.com/openai/v1/`
- **Model:** `openai/gpt-oss-120b`
- **Env var:** `export GROQ_API_KEY="your-key-here"`

---

## Cloudflare Workers AI

**Models:** Llama 3.3 70B, Llama 4 Scout, gpt-oss-120b, Gemma 4 26B, GLM-4.7-Flash, Mistral Small 3.1, DeepSeek-R1-Distill-Qwen-32B +72 more
**Limits:** 10,000 Neurons/day shared across all models, resets 00:00 UTC. Going over fails the request, it never bills you.
**Notes:** Kimi K2.6 / K2.7 Code, GLM-5.2 and DeepSeek V4 Flash / Pro need the paid plan.

### Get your API key

1. Go to [Cloudflare API Tokens](https://dash.cloudflare.com/profile/api-tokens).
2. Sign in or create a Cloudflare account.
3. Create an API token with the "Workers AI" permission.
4. Note your Account ID from the dashboard sidebar.

- **Base URL (OpenAI-compatible):** `https://api.cloudflare.com/client/v4/accounts/<ACCOUNT_ID>/ai/v1/`
- **Native URL:** `https://api.cloudflare.com/client/v4/accounts/<ACCOUNT_ID>/ai/run`
- **Model:** `@cf/meta/llama-3.3-70b-instruct-fp8-fast`
- **Env vars:**
  ```bash
  export CLOUDFLARE_API_TOKEN="your-token-here"
  export CLOUDFLARE_ACCOUNT_ID="your-account-id"
  ```

---

## OpenRouter

**Models:** 17 free models with the `:free` suffix, e.g. `nvidia/nemotron-3-super-120b-a12b:free`, `openai/gpt-oss-20b:free`, `google/gemma-4-31b-it:free`, `poolside/laguna-s-2.1:free`, `cohere/north-mini-code:free`
**Limits:** 20 RPM, 50 RPD per model. A one-time $10+ credit purchase raises free models to 1,000 RPD.
**Notes:** `openrouter/free` auto-picks a free model. Free providers may log prompts for training.

### Get your API key

1. Go to [OpenRouter Keys](https://openrouter.ai/keys).
2. Create an account or sign in.
3. Click "Create Key" and copy it.

- **Base URL:** `https://openrouter.ai/api/v1/`
- **Model:** `openai/gpt-oss-20b:free`
- **Env var:** `export OPENROUTER_API_KEY="your-key-here"`

---

## Kilo Code

**Models:** `kilo-auto/free` (auto-router), `nvidia/nemotron-3-ultra-550b-a55b:free`, `nvidia/nemotron-3-super-120b-a12b:free`, `stepfun/step-3.7-flash:free`, `poolside/laguna-s-2.1:free`, `cohere/north-mini-code:free`, `tencent/hy3:free` +more
**Limits:** 200 requests/hour per IP
**Notes:** Free models need no API key. The free pool changes frequently. The auto-router may use providers that log prompts, and NVIDIA free endpoints are "trial use only, do not submit personal or confidential data."

### Get your API key (optional)

1. Go to [Kilo profile](https://app.kilo.ai/profile) if you want a key; otherwise call without one.

- **Base URL:** `https://api.kilo.ai/api/gateway`
- **Model:** `kilo-auto/free`
- **Env var:** `export KILO_API_KEY="your-key-here"` (optional)

---

## Ollama Cloud

**Models:** deepseek-v4-pro, deepseek-v4-flash, kimi-k3, minimax-m3, `gpt-oss:120b`, `gpt-oss:20b`, nemotron-3-ultra, `mistral-large-3:675b`, `qwen3.5:397b` +7 more
**Limits:** Session limits reset every 5 hours, weekly limits every 7 days (numbers unpublished). Usage is weighted by input, cached input and output tokens per model.

### Get your API key

1. Go to [Ollama keys](https://ollama.com/settings/keys).
2. Create an account or sign in.
3. Create a key and copy it.

- **Base URL (OpenAI-compatible):** `https://ollama.com/v1/`
- **Native URL:** `https://ollama.com/api`
- **Model:** `gpt-oss:120b`
- **Env var:** `export OLLAMA_API_KEY="your-key-here"`

---

## OVHcloud AI Endpoints

**Models:** Qwen3.5-397B-A17B, gpt-oss-120b, gpt-oss-20b, Meta-Llama-3_3-70B-Instruct, Qwen3.6-27B, Qwen3-32B, Qwen3-Coder-30B-A3B-Instruct, Qwen2.5-VL-72B-Instruct, Mistral-Small-3.2-24B-Instruct +more
**Limits:** 2 RPM per IP per model, anonymous
**Notes:** No signup and no key needed. Hosted in EU data centers. A key gives 400 RPM but is billed per token.

### Usage

No key needed. Browse the [catalog](https://www.ovhcloud.com/en/public-cloud/ai-endpoints/catalog/) for exact model IDs.

- **Base URL:** `https://oai.endpoints.kepler.ai.cloud.ovh.net/v1/`
- **Model:** `gpt-oss-120b`
- The OpenAI SDK requires a non-empty `api_key`; pass any placeholder string for anonymous use.

---

## LLM7.io

**Models:** `gpt-oss:20b`, mistral-Nemo-Instruct-2407, minimax-m2.7 (catalog rotates often)
**Limits:** Anonymous: 10 RPM, 60 req/hr, 500K tokens/day. Free token: 40 RPM, 100 req/hr, 1M tokens/day.
**Notes:** Anonymous access works without a key. A free token raises limits but reaches the same `turbo` models.

### Get your API key (optional)

1. Go to [LLM7 Token page](https://token.llm7.io).
2. Register or sign in and copy the token.

- **Base URL:** `https://api.llm7.io/v1/`
- **Model:** `gpt-oss:20b`
- **Env var:** `export LLM7_API_KEY="your-token-here"` (optional)

---

## Hugging Face

**Models:** Meta-Llama-3.1-8B-Instruct, gemma-3-4b-it, phi-4, Qwen2.5-7B-Instruct, Qwen2.5-Coder-7B-Instruct + thousands more
**Limits:** $0.10/month in Inference Provider credits (subject to change)
**Notes:** Routes to Fireworks, Together, Hyperbolic, Nebius, Novita, DeepInfra and others.

### Get your API key

1. Go to [Hugging Face Tokens](https://huggingface.co/settings/tokens).
2. Create an account or sign in.
3. Create a token with the "Make calls to Inference Providers" permission.

- **Base URL:** `https://router.huggingface.co/v1/`
- **Model:** `meta-llama/Llama-3.1-8B-Instruct`
- **Env var:** `export HF_TOKEN="your-token-here"`

---

## ModelScope

**Models:** `Qwen/Qwen3.5-35B-A3B`, `Qwen/Qwen3.5-27B` + other API-Inference-enabled models
**Limits:** 2,000 RPD total, ≤500 RPD per model (dynamic); concurrency is dynamically limited
**Notes:** Requires Alibaba Cloud account binding and real-name verification.

### Get your API key

1. Go to [ModelScope access tokens](https://modelscope.cn/my/myaccesstoken).
2. Register, bind an Alibaba Cloud account and complete real-name verification.
3. Copy the access token.

- **Base URL:** `https://api-inference.modelscope.cn/v1/`
- **Model:** `Qwen/Qwen3.5-27B`
- **Env var:** `export MODELSCOPE_API_KEY="your-token-here"`

---

## SiliconFlow

**Models:** `Qwen/Qwen3-8B` (most of the 100+ catalog models are paid)
**Limits:** 1,000 RPM, 50,000 TPM
**Notes:** Real-name verification required since 2026-05-15. It supports mainland-Chinese documents; international users must contact support.

### Get your API key

1. Go to [SiliconFlow API keys](https://cloud.siliconflow.cn/account/ak).
2. Register and complete identity verification.
3. Create a key and copy it.

- **Base URL:** `https://api.siliconflow.cn/v1/`
- **Model:** `Qwen/Qwen3-8B`
- **Env var:** `export SILICONFLOW_API_KEY="your-key-here"`
