# Self-Hosted Gateways - Setup Guides

Gateways you run on your own machine. They don't issue free keys themselves: they put one OpenAI-compatible endpoint in front of the free (and paid) providers you connect, and fail over between them. The gateway's own API key is a local key you create in its dashboard.

## OmniRoute

**What it is:** Free, MIT-licensed, self-hosted AI gateway. One endpoint for 350+ providers, 150+ of them with free tiers, with automatic fallback (subscription → API key → cheap → free) and token compression.
**Repo:** [diegosouzapw/OmniRoute](https://github.com/diegosouzapw/OmniRoute) (synced 2026-09-22)
**Limits:** Whatever the connected providers allow. The dashboard shows the used and remaining free budget at `/dashboard/free-tiers`.
**Notes:**
- No npm account is needed to install. It only needs Node.js, which ships with npm.
- It only runs while the machine hosting it is on.
- Its terms-risk catalog marks 13 providers "avoid". Subscription OAuth and web-cookie providers can break the upstream provider's terms and get accounts banned. Prefer official free API keys, e.g. the ones in [provider-apis.md](provider-apis.md) and [inference-providers.md](inference-providers.md).
- Free upstream providers may log prompts. Don't send confidential data.

### Install and run

1. Install Node.js LTS from [nodejs.org](https://nodejs.org), then check with `node -v` and `npm -v`.
2. Install OmniRoute:
   ```bash
   npm install -g omniroute
   ```
   `npm warn ERESOLVE` or peer-dependency warnings are harmless.
3. Start it with a first-login password. There is no hardcoded default.
   ```bash
   # macOS / Linux
   INITIAL_PASSWORD="your-password" omniroute
   ```
   ```powershell
   # Windows PowerShell
   $env:INITIAL_PASSWORD="your-password"; omniroute
   ```
   Docker alternative:
   ```bash
   docker run -d --name omniroute --restart unless-stopped \
     -e INITIAL_PASSWORD="your-password" \
     -p 127.0.0.1:20128:20128 -v omniroute-data:/app/data diegosouzapw/omniroute:latest
   ```
4. Open the dashboard at `http://localhost:20128` and sign in with that password.

### Connect free providers

In the dashboard, go to **Providers**:
- **OpenCode Free** needs no auth and is pre-wired into the `auto` model, so a fresh install answers immediately.
- **Kiro AI** gives free Claude, about 50 credits/month per account (OAuth; check the terms-risk note above).
- Add official free keys (Gemini, Groq, NVIDIA NIM, Mistral, OpenRouter...) so they join the fallback chain.

### Get the OmniRoute API key (optional by default)

By default `REQUIRE_API_KEY=false` and the server binds to `127.0.0.1`, so local calls to `/v1` work without any key. If you set `REQUIRE_API_KEY=true` (needed before exposing it on a LAN or the internet), go to **Endpoints** in the dashboard and copy the key. Many clients, including the OpenAI SDK, still require a non-empty `api_key`: pass the real key, or any placeholder string when keys aren't enforced.

Upstream providers are separate: OpenCode Free needs no key, while Gemini, Groq and the like need their own free keys registered under **Providers**.

- **Base URL:** `http://localhost:20128/v1`
- **Model:** `auto` (smart routing), or `provider/model` for a specific backend (e.g. `oc/...` for OpenCode Free)
- **Env var:** `export OMNIROUTE_API_KEY="your-key-here"`

### Usage example

```python
import os
from openai import OpenAI

client = OpenAI(
    api_key=os.environ.get("OMNIROUTE_API_KEY", "none"),  # placeholder works when keys are not enforced
    base_url="http://localhost:20128/v1"
)

response = client.chat.completions.create(
    model="auto",
    messages=[{"role": "user", "content": "Hello!"}]
)
print(response.choices[0].message.content)
```

Verify with curl:

```bash
curl http://localhost:20128/v1/models -H "Authorization: Bearer $OMNIROUTE_API_KEY"
```
