#!/usr/bin/env bash
set -euo pipefail

TITLE="${1:-pi Agent}"
MESSAGE="${2:-Task complete}"
IDLE_THRESHOLD_SECONDS="${PI_NOTIFY_IDLE_THRESHOLD_SECONDS:-300}"

send_macos_notification() {
  osascript - "${TITLE}" "${MESSAGE}" <<'APPLESCRIPT' 2>/dev/null || true
on run argv
  display notification (item 2 of argv) with title (item 1 of argv) sound name "Glass"
end run
APPLESCRIPT
}

send_ntfy_notification() {
  if [[ -z "${PI_NOTIFY_NTFY_SERVER:-}" || -z "${PI_NOTIFY_NTFY_TOPIC:-}" || -z "${PI_NOTIFY_NTFY_TOKEN:-}" ]]; then
    echo "Warning: ntfy notification is not configured" >&2
    return 0
  fi

  if ! command -v curl >/dev/null 2>&1; then
    echo "Warning: curl is required for ntfy notifications" >&2
    return 0
  fi

  local server="${PI_NOTIFY_NTFY_SERVER%/}"
  curl -fsS \
    -H "Authorization: Bearer ${PI_NOTIFY_NTFY_TOKEN}" \
    -H "Title: ${TITLE}" \
    -H "Priority: default" \
    --data-binary "${MESSAGE}" \
    "${server}/${PI_NOTIFY_NTFY_TOPIC}" >/dev/null || true
}

idle_seconds() {
  ioreg -c IOHIDSystem 2>/dev/null | awk '/HIDIdleTime/ { print int($NF / 1000000000); exit }'
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  send_ntfy_notification
  exit 0
fi

IDLE_SECONDS="$(idle_seconds)"
if [[ -z "${IDLE_SECONDS}" ]]; then
  send_ntfy_notification
  exit 0
fi

if (( IDLE_SECONDS >= IDLE_THRESHOLD_SECONDS )); then
  send_ntfy_notification
else
  send_macos_notification
fi
