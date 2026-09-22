# Keep Working When Claude Usage Runs Out

How to continue a Claude Code task on free models when the user hits their Claude usage limit or runs out of credits, then switch back once it resets.

Source: OmniRoute's [Claude Code configuration guide](https://github.com/diegosouzapw/OmniRoute/blob/main/docs/guides/CLAUDE-CODE-CONFIGURATION.md) (synced 2026-09-22). Setup steps for OmniRoute itself are in [gateways.md](gateways.md).

## Tell the user first

- **Local CLI only.** This works for the Claude Code CLI (`claude`) on the user's own machine. Claude Code on the web, desktop or mobile app cloud sessions can't change their model endpoint. There, the options are waiting for the limit to reset or adding usage on their plan.
- **Free models are weaker agents.** Expect lower quality on multi-file edits and more failed tool calls than with Claude. Treat it as a stopgap to keep momentum, and review the diff before committing.
- **Use official free API keys only.** Don't pool several Claude accounts, or route Claude subscriptions or unofficial "free Claude" providers (OAuth or web-cookie) through the gateway to dodge limits. That can break Anthropic's or the provider's terms and get accounts suspended. Connect keys such as Gemini, Groq or NVIDIA NIM from [provider-apis.md](provider-apis.md) and [inference-providers.md](inference-providers.md).
- Free providers may log prompts. Don't send confidential code.

## One-time setup

1. Install and start OmniRoute, then open the dashboard at `http://localhost:20128` (see [gateways.md](gateways.md)).
2. Under **Providers**, add official free keys. Good defaults: Google Gemini, Groq, NVIDIA NIM.
3. Under **Endpoints**, copy the OmniRoute API key. Claude Code needs a token even when OmniRoute doesn't enforce keys.

## When the limit hits

Run these from the same project folder.

**Option A: launcher.** This starts `claude` with the gateway variables injected and health-checks the server first.

```bash
omniroute launch
```

**Option B: environment variables.** `ANTHROPIC_BASE_URL` is the gateway root. Claude Code appends `/v1/messages` itself, so **don't add `/v1`**.

```bash
# macOS / Linux
ANTHROPIC_BASE_URL=http://localhost:20128 ANTHROPIC_AUTH_TOKEN=<omniroute-key> claude --continue
```

```powershell
# Windows PowerShell
$env:ANTHROPIC_BASE_URL="http://localhost:20128"
$env:ANTHROPIC_AUTH_TOKEN="<omniroute-key>"
claude --continue
```

- `--continue` reopens the most recent conversation in that folder. If replaying the Claude-generated history to another model errors out, start a fresh `claude` session and resume from the progress file below.
- Optional `ANTHROPIC_MODEL=<omniroute-model-id>` forces one model. Otherwise OmniRoute routes the request.
- Claude Code assumes a 200K context window for model IDs it doesn't recognize. For a model with a different window, set `CLAUDE_CODE_AUTO_COMPACT_WINDOW` below the model's real window.
- Env vars are read once at startup: restart `claude` after changing them.

To return to Claude after the limit resets, open a new terminal (or clear both variables in PowerShell with `Remove-Item Env:ANTHROPIC_BASE_URL, Env:ANTHROPIC_AUTH_TOKEN`) and run `claude --continue`.

## Make hand-offs painless

These help whichever model picks the work up:

- **Commit often.** Any tool can resume from git state.
- **Keep a progress file.** Have Claude maintain `PROGRESS.md` in the repo with the current goal, what's done and the next steps. A good standing instruction is: "Update PROGRESS.md whenever you finish a step." After switching models, the first prompt is "Read PROGRESS.md and continue."
- **Keep `CLAUDE.md` current** with build and test commands, so a new session doesn't have to rediscover them.
