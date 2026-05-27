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

The helper script sends:

- a native macOS notification when the Mac appears active
- an ntfy notification when the Mac appears idle, unavailable, or not running macOS

Idle detection uses macOS HID idle time. The default idle threshold is 300 seconds.

## Install

Copy this directory into your pi agent skills directory:

```bash
mkdir -p ~/.pi/agent/skills
cp -R notify ~/.pi/agent/skills/notify
```

## Usage

Ask pi to notify you when work is done:

```text
Run the checks and notify me when done.
```

The skill will run this script as the last command before the final response:

```bash
./scripts/notify.sh "pi Agent" "Task complete"
```

## Optional ntfy fallback

Set these environment variables to enable ntfy fallback notifications:

```bash
export PI_NOTIFY_NTFY_SERVER="https://ntfy.sh"
export PI_NOTIFY_NTFY_TOPIC="your-topic"
export PI_NOTIFY_NTFY_TOKEN="your-token"
```

Optional idle threshold override:

```bash
export PI_NOTIFY_IDLE_THRESHOLD_SECONDS=300
```

## Files

- `SKILL.md` - pi skill instructions
- `scripts/notify.sh` - notification helper
