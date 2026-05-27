#!/usr/bin/env bash
set -euo pipefail

# Usage: ./notify.sh "<message>" ["<agent-label>"]
MESSAGE="${1:-Task complete}"
AGENT_LABEL="${2:-$(whoami)}"
IDLE_THRESHOLD_SECONDS="${PI_NOTIFY_IDLE_THRESHOLD_SECONDS:-300}"

# ------------------------------------------------------------------
# Build the notification title.
#   In a git repo:   user@host repo (branch) [session]
#   Not in a repo:   user@host                    [session]
#   Override (PI_NOTIFY_TITLE): use exactly that string.
# ------------------------------------------------------------------
build_title() {
  # Full manual override — use exactly what the user set
  if [[ -n "${PI_NOTIFY_TITLE:-}" ]]; then
    echo "${PI_NOTIFY_TITLE}"
    return
  fi

  local label="$AGENT_LABEL"

  # ----- hostname -----
  local hostname
  hostname="$(hostname -s 2>/dev/null || hostname 2>/dev/null || echo "unknown")"

  # ----- git repo context: only show when in a git repo -----
  local location=""
  local repo_root
  repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
  if [[ -n "$repo_root" ]]; then
    local repo_name branch
    repo_name="$(basename "$repo_root")"
    branch="$(git branch --show-current 2>/dev/null || git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")"
    if [[ -n "$branch" && "$branch" != "HEAD" ]]; then
      location="${repo_name} (${branch})"
    else
      location="${repo_name}"
    fi
  fi

  # ----- optional session label (multiple concurrent agents) -----
  local session="${PI_NOTIFY_SESSION_NAME:-}"

  # ----- assemble -----
  local title="${label}@${hostname}"
  if [[ -n "$location" ]]; then
    title="${title} ${location}"
  fi
  if [[ -n "$session" ]]; then
    title="${title} [${session}]"
  fi

  echo "${title}"
}

TITLE="$(build_title)"

# ------------------------------------------------------------------
# Notification backends
# ------------------------------------------------------------------

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

# ------------------------------------------------------------------
# Dispatch
# ------------------------------------------------------------------

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
