# Keep Working When Claude Usage Runs Out

How to continue a Claude Code task on free models when the user hits their Claude usage limit or runs out of credits, then switch back once it resets.

Source: OmniRoute's [Claude Code configuration guide](https://github.com/diegosouzapw/OmniRoute/blob/main/docs/guides/CLAUDE-CODE-CONFIGURATION.md) (synced 2026-09-22), plus fixes found while running it end to end on Windows 11. Setup steps for OmniRoute itself are in [gateways.md](gateways.md).

## Tell the user first

- **Local CLI only.** This works for the Claude Code CLI (`claude`) on the user's own machine. Claude Code on the web, desktop or mobile app cloud sessions can't change their model endpoint. There, the options are waiting for the limit to reset or adding usage on their plan.
- **Free models are weaker agents.** Expect lower quality on multi-file edits and more failed tool calls than with Claude. Treat it as a stopgap to keep momentum, and review the diff before committing.
- **Use official free API keys only.** Don't pool several Claude accounts, or route Claude subscriptions or unofficial "free Claude" providers (OAuth or web-cookie) through the gateway to dodge limits. That can break Anthropic's or the provider's terms and get accounts suspended. Connect keys such as Gemini, Groq or NVIDIA NIM from [provider-apis.md](provider-apis.md) and [inference-providers.md](inference-providers.md).
- Free providers may log prompts. Don't send confidential code.

## One-time setup

1. Install and start OmniRoute, then open the dashboard at `http://127.0.0.1:20128` (see [gateways.md](gateways.md)).
2. Under **Providers**, add official free keys. Good defaults: Google Gemini, Groq, NVIDIA NIM. OpenCode Free (No Auth) is already there.
3. Under **Endpoints** / **API Manager**, create an **OmniRoute** key. This is not the Gemini key: see "Two different keys" in [gateways.md](gateways.md). Claude Code needs a token even when OmniRoute doesn't enforce keys.
4. Check Claude Code runs: `claude --version`. If that fails, see Troubleshooting below.

## When the limit hits

1. Start the OmniRoute server in its own terminal and leave it alone (see [gateways.md](gateways.md)).
2. In a **second** terminal, go to the project folder and run the matching block.

All three variables matter:
- `ANTHROPIC_BASE_URL` is the gateway root. Claude Code appends `/v1/messages` itself, so **don't add `/v1`**. Use `127.0.0.1`, not `localhost`: on Windows `localhost` can resolve to IPv6 and give `ECONNREFUSED`. Plain `http` is correct.
- `ANTHROPIC_AUTH_TOKEN` is the OmniRoute key.
- `ANTHROPIC_MODEL=auto` is needed. Without it Claude Code asks for `claude-*` model IDs, which no free provider serves.

```cmd
:: Windows cmd — no spaces around =, no quotes
set ANTHROPIC_BASE_URL=http://127.0.0.1:20128
set ANTHROPIC_AUTH_TOKEN=<omniroute-key>
set ANTHROPIC_MODEL=auto
claude --continue
```

```powershell
# Windows PowerShell
$env:ANTHROPIC_BASE_URL="http://127.0.0.1:20128"
$env:ANTHROPIC_AUTH_TOKEN="<omniroute-key>"
$env:ANTHROPIC_MODEL="auto"
claude --continue
```

```bash
# macOS / Linux
ANTHROPIC_BASE_URL=http://127.0.0.1:20128 ANTHROPIC_AUTH_TOKEN=<omniroute-key> ANTHROPIC_MODEL=auto claude --continue
```

Launcher alternative: `omniroute launch --remote http://127.0.0.1:20128 --api-key <omniroute-key>`. Plain `omniroute launch` probes `localhost` and can wrongly report the server as unreachable on Windows.

- On the first run in a folder, pick **Yes, I trust this folder**. Then type the task at Claude Code's `>` prompt, not at the shell prompt.
- The header should read `auto · API Usage Billing`. If a Claude login screen appears instead, the variables weren't applied in that terminal.
- A yellow `"auto" isn't described by this version's model catalog` warning is expected. It only means Claude Code assumes a 200K context window. For a model with a different window, set `CLAUDE_CODE_AUTO_COMPACT_WINDOW` below the model's real window.
- `--continue` reopens the most recent conversation in that folder. If replaying the Claude-generated history to another model errors out, start a fresh `claude` session and resume from the progress file below.
- Env vars are read once at startup: restart `claude` after changing them.

To return to Claude after the limit resets, open a **new** terminal (the `set` / `$env:` values only live in the window where they were set) and run `claude --continue`.

### One-click launcher for Windows (optional)

Save as `claude-free.bat` in the project folder and double-click it. It asks for the key each time instead of storing it in the file.

```bat
@echo off
set ANTHROPIC_BASE_URL=http://127.0.0.1:20128
set /p ANTHROPIC_AUTH_TOKEN=OmniRoute key: 
set ANTHROPIC_MODEL=auto
cd /d "%~dp0"
claude --continue
```

## Troubleshooting (seen on Windows)

| Symptom | Cause | Fix |
|---|---|---|
| `'$env:...' is not recognized` | PowerShell syntax typed in cmd | Use the cmd `set` form |
| `'hello.txt ...' is not recognized as an internal or external command` | Task typed at the cmd prompt | Run `claude` first, then type at its `>` prompt |
| `Connection refused` / `ECONNREFUSED` | OmniRoute server stopped, or `localhost` resolving to IPv6 | `curl http://127.0.0.1:20128/v1/models -H "Authorization: Bearer <key>"` from another terminal. If it fails, restart `omniroute serve` in its own window. If it works, use `127.0.0.1` and check `set \| findstr /i proxy` (then `set NO_PROXY=127.0.0.1,localhost`) |
| `OmniRoute is not reachable at http://localhost:20128` from `omniroute launch` | Same `localhost` issue, or server down | `omniroute launch --remote http://127.0.0.1:20128 --api-key <key>` |
| `Authentication required` | Server enforces keys | Pass the OmniRoute key |
| `invalid key` | Provider key (e.g. Gemini) used as the OmniRoute key | Create an OmniRoute key under Endpoints / API Manager |
| `claude.exe ... is not compatible with the version of Windows` | Broken npm install; the `claude.exe` was a 500-byte stub | `npm uninstall -g @anthropic-ai/claude-code`, then install with the official script in PowerShell: `irm https://claude.ai/install.ps1 \| iex` |
| `'claude' is not recognized` after the official install | `%USERPROFILE%\.local\bin` not on PATH | In PowerShell: `[Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path","User") + ";$env:USERPROFILE\.local\bin", "User")`, then open a new terminal and check `where claude` |

## Make hand-offs painless

These help whichever model picks the work up:

- **Commit often.** Any tool can resume from git state.
- **Keep a progress file.** Have Claude maintain `PROGRESS.md` in the repo with the current goal, what's done and the next steps. A good standing instruction is: "Update PROGRESS.md whenever you finish a step." After switching models, the first prompt is "Read PROGRESS.md and continue."
- **Keep `CLAUDE.md` current** with build and test commands, so a new session doesn't have to rediscover them.
