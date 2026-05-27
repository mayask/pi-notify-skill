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
./scripts/notify.sh "<title>" "<message>"
```

- `<title>`: usually `"pi Agent"` or a domain-specific title (e.g., `"Tests"`, `"Deploy"`).
- `<message>`: a concise 1-sentence summary of what was completed, or a failure note if something went wrong. Keep it under 120 characters.

### Examples

After a successful task:
```bash
./scripts/notify.sh "pi Agent" "Refactored user repository and updated tests"
```

After a partial failure:
```bash
./scripts/notify.sh "pi Agent" "Refactored user repository; 2 tests still failing"
```

## Important Rules

- **Only send one notification per user prompt.** Even if the task spanned multiple files or steps, send a single summary notification at the end.
- Presence is determined by macOS HID idle time. The default idle threshold is 300 seconds and can be overridden with `PI_NOTIFY_IDLE_THRESHOLD_SECONDS`.
- If the Mac appears idle, locked away, or the OS is not macOS, the script sends via ntfy when configured with environment variables: `PI_NOTIFY_NTFY_SERVER`, `PI_NOTIFY_NTFY_TOPIC`, and `PI_NOTIFY_NTFY_TOKEN`.
- Do not store ntfy credentials in the skill directory or commit them to source control.
- **Do not mention the notification** in your final response unless the user explicitly asks about it.
