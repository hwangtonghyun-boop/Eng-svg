# Provider APIs - Setup Guides

APIs run by the companies that train or fine-tune the models themselves.

## Google Gemini

**Models:** Gemini 3.7 / 3.6 / 3.5 Flash, 3.5 Flash-Lite, 2.5 Pro, 2.5 Flash, Gemma 4 31B +more
**Limits:** Flash 15 RPM / 1,500 RPD, Flash-Lite 30 RPM / 1,500 RPD, 2.5 Pro 5 RPM / 50 RPD
**Context:** 1M tokens, text + image + audio + video input
**Notes:** Google no longer publishes per-model free limits; check quotas in AI Studio. Free-tier prompts may be used to improve Google products (not in the EEA, UK or Switzerland). `gemini-3.1-flash-lite` shuts down 2027-05-07.

### Get your API key

1. Go to [Google AI Studio](https://aistudio.google.com/app/apikey).
2. Sign in with a Google account.
3. Click "Create API Key" and select or create a Google Cloud project.
4. Copy the generated key.

### Usage example

```python
import os
from openai import OpenAI

client = OpenAI(
    api_key=os.environ["GEMINI_API_KEY"],
    base_url="https://generativelanguage.googleapis.com/v1beta/openai/"
)

response = client.chat.completions.create(
    model="gemini-2.5-flash",
    messages=[{"role": "user", "content": "Hello!"}]
)
print(response.choices[0].message.content)
```

The native (non-OpenAI) base URL is `https://generativelanguage.googleapis.com/v1beta`. Newer models (e.g. Gemini 3.5 Flash) are also free; get their exact IDs from AI Studio.

### Environment variable

```bash
export GEMINI_API_KEY="your-key-here"
```

---

## Mistral AI

**Models:** Mistral Medium 3.5 (128B), Mistral Large 3, Mistral Small 4, Codestral, Ministral 3 (3B / 8B / 14B)
**Limits:** $10/month in API credits, ~1 RPS, 500K TPM (last published values)
**Context:** 256K (Codestral 128K)
**Notes:** Free mode is on by default for new accounts. The monthly allowance is shared across Studio, the API and Vibe Code. Free-mode prompts may be used for training; opt out in settings. Current limits are on the Limits page of the admin panel.

### Get your API key

1. Go to the [Mistral Console](https://console.mistral.ai/api-keys).
2. Create an account or sign in.
3. Go to API Keys and create a new key.
4. Copy the key.

### Usage example

```python
import os
from openai import OpenAI

client = OpenAI(
    api_key=os.environ["MISTRAL_API_KEY"],
    base_url="https://api.mistral.ai/v1/"
)

response = client.chat.completions.create(
    model="mistral-small-latest",
    messages=[{"role": "user", "content": "Hello!"}]
)
print(response.choices[0].message.content)
```

### Environment variable

```bash
export MISTRAL_API_KEY="your-key-here"
```

---

## Z AI (Zhipu AI)

**Models:** GLM-4.7-Flash (200K, reasoning), GLM-4.6V-Flash (multimodal), GLM-4.5-Flash (retirement announced, routes to 4.7-Flash)
**Limits:** 1 concurrent request
**Notes:** Overseas phone numbers are accepted, and the chat API does not require real-name verification (the Batch API does). The international platform serves the same free models.

### Get your API key

1. Go to [Z AI international](https://z.ai) or [Zhipu BigModel](https://open.bigmodel.cn/usercenter/apikeys).
2. Sign up (overseas phone numbers work).
3. Go to API Keys and create a new key.
4. Copy the key.

### Usage example

```python
import os
from openai import OpenAI

client = OpenAI(
    api_key=os.environ["ZHIPU_API_KEY"],
    base_url="https://api.z.ai/api/paas/v4/"  # or https://open.bigmodel.cn/api/paas/v4/
)

response = client.chat.completions.create(
    model="glm-4.7-flash",
    messages=[{"role": "user", "content": "Hello!"}]
)
print(response.choices[0].message.content)
```

### Environment variable

```bash
export ZHIPU_API_KEY="your-key-here"
```

---

## Aion Labs

**Models:** aion-3.0, aion-3.0-mini, aion-2.0 (reasoning), aion-rp-llama-3.1-8b
**Limits:** 15 RPM, 20K tokens/day
**Notes:** Specialized for roleplay and storytelling.

### Get your API key

1. Go to [Aion Labs API keys](https://www.aionlabs.ai/app/api-keys/).
2. Create an account or sign in.
3. Create a new key and copy it.

### Usage example

```python
import os
from openai import OpenAI

client = OpenAI(
    api_key=os.environ["AION_API_KEY"],
    base_url="https://api.aionlabs.ai/v1/"
)

response = client.chat.completions.create(
    model="aion-labs/aion-3.0-mini",
    messages=[{"role": "user", "content": "Hello!"}]
)
print(response.choices[0].message.content)
```

### Environment variable

```bash
export AION_API_KEY="your-key-here"
```

---

## Cohere

**Models:** Command A+ (218B), Command A (111B), Command A Reasoning, Command A Vision, Command A Translate, Command R+, Command R, Command R7B, Aya Expanse 32B, Aya Vision 32B
**Limits:** 20 RPM, 1,000 API calls/month
**Notes:** Free "Trial" key. **Non-commercial use only.**

### Get your API key

1. Go to the [Cohere Dashboard](https://dashboard.cohere.com/api-keys).
2. Create an account or sign in.
3. Go to API Keys and generate a trial key.
4. Copy the key.

### Usage example

Cohere's native API lives at `https://api.cohere.com/v2`. With the OpenAI SDK, use its compatibility endpoint:

```python
import os
from openai import OpenAI

client = OpenAI(
    api_key=os.environ["CO_API_KEY"],
    base_url="https://api.cohere.ai/compatibility/v1/"
)

response = client.chat.completions.create(
    model="command-a-03-2025",
    messages=[{"role": "user", "content": "Hello!"}]
)
print(response.choices[0].message.content)
```

### Environment variable

```bash
export CO_API_KEY="your-key-here"
```
