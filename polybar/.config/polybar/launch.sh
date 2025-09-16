#!/usr/bin/env bash

set -euo pipefail

BAR_NAME="${BAR_NAME:-main}"                  # change to your bar name from config
LOGFILE="${LOGFILE:-$HOME/.cache/polybar.log}"
LOCKFILE="${LOCKFILE:-$HOME/.cache/polybar.lock}"

# Create cache dir
mkdir -p "$(dirname "$LOGFILE")"

# Acquire an exclusive lock so multiple triggers can't overlap
exec {lock_fd}>"$LOCKFILE"
flock -n "$lock_fd" || exit 0  # another instance is running; bail out quietly

echo "[$(date '+%F %T')] ---- polybar launch start ----" >> "$LOGFILE"

# Ask all existing bars to quit nicely (via IPC, no SIGKILL thrash)
polybar-msg cmd quit >/dev/null 2>&1 || true

# Wait until old polybar processes are gone (max ~3s)
for _ in {1..30}; do
    if ! pgrep -x polybar >/dev/null; then
        break
    fi
    sleep 0.1
done

# Determine active monitors
get_monitors() {
    # Prefer polybar's view of monitors
    if command -v polybar >/dev/null; then
        polybar -m 2>/dev/null | awk -F: '{print $1}'
        return
    fi
    # Fallback to xrandr
    if command -v xrandr >/dev/null; then
        xrandr --query | awk '/ connected( primary)?/{print $1}'
        return
    fi
    # Single-head fallback
    echo "eDP-1"
}

MONITORS=()
while IFS= read -r m; do
    [[ -n "$m" ]] && MONITORS+=("$m")
done < <(get_monitors)

if [[ ${#MONITORS[@]} -eq 0 ]]; then
    echo "[$(date '+%F %T')] No monitors detected; not launching polybar." >> "$LOGFILE"
    exit 0
fi

# Launch exactly one bar per monitor
for m in "${MONITORS[@]}"; do
    echo "[$(date '+%F %T')] Launching bar '$BAR_NAME' on $m" >> "$LOGFILE"
    MONITOR="$m" polybar --reload "$BAR_NAME" >> "$LOGFILE" 2>&1 &
done

disown

echo "[$(date '+%F %T')] ---- polybar launch done ----" >> "$LOGFILE"
