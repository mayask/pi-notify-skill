---
name: notify
description: Send a completion notification when a task finishes. Use when the user's prompt contains phrases like "report back", "notify me", "ping me when done", "let me know when done", "alert me when complete", or similar requests to be alerted on task completion.
---

# Notify

## Trigger Phrases

Activate this skill when the user prompt includes any of the following (or close variants):

- "report back"
- "notify me"
- "ping me when done"
- "let me know when done"
- "alert me when complete"
- "send a notification when"

## Behavior

1. **Acknowledge silently.** Do not tell the user you will send a notification — just do it.
2. **Do the work.** Complete all requested tasks normally.
3. **Send the notification** as the **very last `bash` call** before your final response to the user. Use the helper script below. It sends a native macOS notification when the user appears present, and an ntfy notification when the Mac appears idle or unavailable.
4. **Then respond normally.** Summarize what you did in the chat as usual.

## Notification Script

Run from the skill directory:

```bash
./scripts/notify.sh "<message>" ["<agent-label>"]
```

- `<message>`: a concise 1-sentence summary of what was completed, or a failure note if something went wrong. Keep it under 120 characters.
- `<agent-label>` (optional): overrides the username as the agent name in the title. Use a short label like `"Deploy"`, `"Format"`, or `"Lint"` when the task is a specific domain action.

The title is automatically built from the environment:

| Component | Source | Example |
|-----------|--------|---------|
| Agent label | first arg (or `whoami`) | `maxim` / `Deploy` |
| Hostname | `hostname -s` | `mbp` / `desktop` |
| OS | `uname -s` | `macOS` / `Linux` |
| Location | git repo basename (or dir basename, or `~`) | `pi-notify-skill` |
| Branch | `git branch --show-current` | `main` / `feat/new-feature` |
| Session | `PI_NOTIFY_SESSION_NAME` env var | `work` / `swe-1` |

Resulting title format: `pi@host [OS] repo (branch)` or `pi@host [OS] repo (branch) [session]`

### Examples

After a successful task:
```bash
./scripts/notify.sh "Refactored user repository and updated tests"
```

After a partial failure:
```bash
./scripts/notify.sh "Refactored user repository; 2 tests still failing"
```

With a domain-specific agent label:
```bash
./scripts/notify.sh "Deployment complete, all pods healthy" "Deploy"
```

## Important Rules

- **Only send one notification per user prompt.** Even if the task spanned multiple files or steps, send a single summary notification at the end.
- Presence is determined by macOS HID idle time. The default idle threshold is 300 seconds and can be overridden with `PI_NOTIFY_IDLE_THRESHOLD_SECONDS`.
- If the Mac appears idle, locked away, or the OS is not macOS, the script sends via ntfy when configured with environment variables: `PI_NOTIFY_NTFY_SERVER`, `PI_NOTIFY_NTFY_TOPIC`, and `PI_NOTIFY_NTFY_TOKEN`.
- Do not store ntfy credentials in the skill directory or commit them to source code.
- **Do not mention the notification** in your final response unless the user explicitly asks about it.

## Environment Variables

| Variable | Purpose |
|----------|---------|
| `PI_NOTIFY_NTFY_SERVER` | ntfy server URL (e.g. `https://ntfy.sh`) |
| `PI_NOTIFY_NTFY_TOPIC` | ntfy topic name |
| `PI_NOTIFY_NTFY_TOKEN` | ntfy auth token |
| `PI_NOTIFY_IDLE_THRESHOLD_SECONDS` | macOS idle threshold before falling back to ntfy (default: 300) |
| `PI_NOTIFY_SESSION_NAME` | Optional label appended to the title (e.g. `work`, `swe-1`). Useful for distinguishing multiple concurrent agents on the same machine. |
| `PI_NOTIFY_TITLE` | Full title override — if set, replaces the entire auto-derived title |
