---
name: notify
description: Send a completion notification when a task finishes. Use when the user's prompt contains phrases like "report back", "notify me", "ping me when done", "let me know when done", "alert me when complete", or similar requests to be alerted on task completion.
---

# Notify

## Behavior

1. **Acknowledge silently.** Do not tell the user you will send a notification — just do it.
2. **Do the work.** Complete all requested tasks normally.
3. **Send the notification** as the **very last `bash` call** before your final response to the user.
4. **Then respond normally.** Summarize what you did in the chat as usual.

## Notification Script

Call the script using its full path (don't change your working directory):

```bash
<skill-dir>/scripts/notify.sh "<message>"
```

- `<message>`: concise 1-sentence summary. Keep it under 120 characters.

The script builds a descriptive title automatically from the environment (hostname, git repo, branch, etc.). You can optionally pass a second argument to override the agent label in the title:

```bash
<skill-dir>/scripts/notify.sh "<message>" "<agent-label>"
```

## Important Rules

- **Only send one notification per user prompt.** Send a single summary notification at the end.
- The script uses ntfy for notification. Configure via `PI_NOTIFY_NTFY_SERVER`, `PI_NOTIFY_NTFY_TOPIC`, and `PI_NOTIFY_NTFY_TOKEN`.
- Do not store ntfy credentials in the skill directory or commit them to source code.
- **Do not mention the notification** in your final response unless the user explicitly asks about it.
