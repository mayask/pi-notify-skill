# notify

A pi skill that sends a completion notification after long-running agent work.

## What it does

When a prompt asks to be notified, the skill tells the agent to send one final notification before responding.

Trigger phrases include:

- `report back`
- `notify me`
- `ping me when done`
- `let me know when done`
- `alert me when complete`
- `send a notification when`

## Notification behavior

The helper script always sends an ntfy notification. It does not use native macOS notifications or idle/uptime tracking.

## Notification titles

The title is automatically built like a shell prefix so you can tell at a glance where a notification is coming from:

```
maxim@mbp pi-notify-skill (main)
maxim@desktop my-project (feat/new-feature)
```

For multiple concurrent agents, set `PI_NOTIFY_SESSION_NAME` and it's appended:

```
maxim@desktop my-project (main) [swe-1]
```

## Install

```bash
pi install git:github.com/mayask/pi-notify-skill
```

### Update

```bash
pi update git:github.com/mayask/pi-notify-skill
```

## Usage

Ask pi to notify you when work is done:

```text
Run the checks and notify me when done.
```

The skill will run this script as the last command before the final response:

```bash
./scripts/notify.sh "Task complete"
```

An optional second argument can label the agent (e.g. `"Deploy"`, `"Lint"`):

```bash
./scripts/notify.sh "Deployment complete" "Deploy"
```

## ntfy configuration

Set these environment variables to enable notifications:

```bash
export PI_NOTIFY_NTFY_SERVER="https://ntfy.sh"
export PI_NOTIFY_NTFY_TOPIC="your-topic"
export PI_NOTIFY_NTFY_TOKEN="your-token"
```

## Customizing notification titles

| Env variable | Purpose |
|---|---|
| `PI_NOTIFY_SESSION_NAME` | Label appended to the title for distinguishing multiple concurrent agents (e.g. `work`, `swe-1`) |
| `PI_NOTIFY_TITLE` | Full override — replaces the entire auto-derived title with your own string |

## Files

- `package.json` - pi package manifest
- `SKILL.md` - pi skill instructions
- `scripts/notify.sh` - notification helper
