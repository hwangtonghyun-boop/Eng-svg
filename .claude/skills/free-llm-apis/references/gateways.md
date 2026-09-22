# Self-Hosted Gateways - Setup Guides

Gateways you run on your own machine. They don't issue free keys themselves: they put one OpenAI-compatible endpoint in front of the free (and paid) providers you connect, and fail over between them. The gateway's own API key is a local key you create in its dashboard.

## OmniRoute

**What it is:** Free, MIT-licensed, self-hosted AI gateway. One endpoint for 350+ providers, 150+ of them with free tiers, with automatic fallback (subscription → API key → cheap → free) and token compression.
**Repo:** [diegosouzapw/OmniRoute](https://github.com/diegosouzapw/OmniRoute) (synced 2026-09-22; setup below was walked through end to end on Windows 11 with OmniRoute v3.8.50)
**Limits:** Whatever the connected providers allow. The dashboard shows the used and remaining free budget at `/dashboard/free-tiers`.
**Notes:**
- No npm account is needed to install. It only needs Node.js, which ships with npm.
- It only runs while the machine hosting it is on, and only while its server process is alive.
- Its terms-risk catalog marks 13 providers "avoid". Subscription OAuth and web-cookie providers can break the upstream provider's terms and get accounts banned. Prefer official free API keys, e.g. the ones in [provider-apis.md](provider-apis.md) and [inference-providers.md](inference-providers.md).
- Free upstream providers may log prompts. Don't send confidential data.

### Install

1. Install Node.js LTS from [nodejs.org](https://nodejs.org), then check with `node -v` and `npm -v`.
2. Install OmniRoute:
   ```bash
   npm install -g omniroute
   ```
   This only installs; it does not start a server. Ending with "added 1000+ packages" is normal, and `npm warn ERESOLVE` or peer-dependency warnings are harmless.

### Start the server

Set a first-login password (there is no hardcoded default) and bind to loopback. Without `OMNIROUTE_SERVER_HOST=127.0.0.1`, v3.8.50 listened on `0.0.0.0` with no API key required, so anything on the same network could use it.

Syntax differs by Windows shell. The prompt tells them apart: `PS C:\...>` is PowerShell, `C:\...>` is cmd. `$env:` lines fail in cmd.

```cmd
:: Windows cmd — no spaces around =, no quotes
set OMNIROUTE_SERVER_HOST=127.0.0.1
set INITIAL_PASSWORD=yourpassword
omniroute serve
```

```powershell
# Windows PowerShell
$env:OMNIROUTE_SERVER_HOST="127.0.0.1"; $env:INITIAL_PASSWORD="yourpassword"; omniroute serve
```

```bash
# macOS / Linux
OMNIROUTE_SERVER_HOST=127.0.0.1 INITIAL_PASSWORD="yourpassword" omniroute serve
```

- Use a password with ASCII letters and digits; non-ASCII characters can break the login.
- **Keep that terminal open and don't type in it.** If the shell prompt comes back after "OmniRoute is running!", the server has stopped. Alternative: `omniroute serve --tray` keeps it running in the system tray without a terminal.
- Docker alternative:
  ```bash
  docker run -d --name omniroute --restart unless-stopped \
    -e INITIAL_PASSWORD="your-password" \
    -p 127.0.0.1:20128:20128 -v omniroute-data:/app/data diegosouzapw/omniroute:latest
  ```

Open the dashboard **in a web browser** (not the terminal) at `http://127.0.0.1:20128` and sign in with that password.

### Connect free providers

In the dashboard, go to **Providers**:
- **OpenCode Free** needs no auth and is pre-wired into the `auto` model, so a fresh install answers immediately. It is listed under the **No Auth** category (orange "OC" icon), not in the default view. Don't paste any key into it.
- **Kiro AI** gives free Claude, about 50 credits/month per account (OAuth; check the terms-risk note above).
- Add official free keys under the **API Key** category (Gemini, Groq, NVIDIA NIM, Mistral, OpenRouter...) so they join the fallback chain.

### Two different keys

Users mix these up; an upstream key sent to OmniRoute returns "invalid key".

| Key | Where it comes from | Where it goes |
|---|---|---|
| Provider key (e.g. Gemini `AIza...`) | The provider's console | Dashboard → **Providers** → that provider, only |
| OmniRoute key (e.g. `sk-...`) | Dashboard → **Endpoints** / **API Manager** → create key | Clients: `Authorization: Bearer`, `ANTHROPIC_AUTH_TOKEN`, `--api-key` |

Whether clients need the OmniRoute key depends on `REQUIRE_API_KEY`. The upstream default is `false`, but in practice it can be on (dashboard setting or `~/.omniroute/.env`). A `401 Authentication required` means the server is up and wants the OmniRoute key. Keep it on and use the key rather than disabling it. Many clients, including the OpenAI SDK and Claude Code, need a non-empty key anyway: pass the real key, or any placeholder when keys aren't enforced.

Treat the OmniRoute key like a password. If it shows up in a screenshot or chat, delete it in the dashboard and create a new one.

### Endpoint

- **Base URL:** `http://127.0.0.1:20128/v1`. Plain `http` is correct: OmniRoute serves HTTP only, loopback traffic never leaves the machine, and `https` fails.
- **Use `127.0.0.1`, not `localhost`.** The server binds IPv4 only. On Windows, `localhost` can resolve to IPv6 `::1` first, so Node-based clients (Claude Code, `omniroute launch`) get `ECONNREFUSED`, while curl still works because it falls back to IPv4.
- **Model:** `auto` (smart routing), or `provider/model` for a specific backend (e.g. `oc/...` for OpenCode Free).
- **Env var:** `OMNIROUTE_API_KEY`

### Verify

Run these from a second terminal while the server terminal stays open.

```cmd
:: Server alive and key accepted: prints a long JSON model list
curl http://127.0.0.1:20128/v1/models -H "Authorization: Bearer <omniroute-key>"

:: A real completion (cmd quoting shown)
curl http://127.0.0.1:20128/v1/chat/completions -H "Content-Type: application/json" -H "Authorization: Bearer <omniroute-key>" -d "{\"model\":\"auto\",\"messages\":[{\"role\":\"user\",\"content\":\"Say hello in one sentence.\"}]}"
```

| Result | Meaning |
|---|---|
| Long JSON list / a reply with `content` | Working |
| `Connection refused` / `ECONNREFUSED` | Server not running: restart it with `omniroute serve` in its own window |
| `Authentication required` | Server up, key missing: add the OmniRoute key |
| `invalid key` | Wrong key, usually a provider key used in place of the OmniRoute key |

`omniroute status` and `omniroute doctor` give more detail.

### Usage example

```python
import os
from openai import OpenAI

client = OpenAI(
    api_key=os.environ.get("OMNIROUTE_API_KEY", "none"),  # placeholder works when keys are not enforced
    base_url="http://127.0.0.1:20128/v1"
)

response = client.chat.completions.create(
    model="auto",
    messages=[{"role": "user", "content": "Hello!"}]
)
print(response.choices[0].message.content)
```
