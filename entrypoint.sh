#!/bin/sh
set -eu

# Determine Happy home directory (mirrors configuration.ts logic)
if [ -n "${HAPPY_HOME_DIR:-}" ]; then
  # Handle tilde expansion manually for POSIX sh
  case "$HAPPY_HOME_DIR" in
    "~"*) HAPPY_HOME="$HOME${HAPPY_HOME_DIR#\~}" ;;
    *) HAPPY_HOME="$HAPPY_HOME_DIR" ;;
  esac
else
  HAPPY_HOME="$HOME/.happy"
fi

SETTINGS_FILE="$HAPPY_HOME/settings.json"
ACCESS_KEY_FILE="$HAPPY_HOME/access.key"

mkdir -p "$HAPPY_HOME"

if [ ! -f "$SETTINGS_FILE" ]; then
  if command -v uuidgen >/dev/null 2>&1; then
    MACHINE_ID="$(uuidgen)"
  else
    MACHINE_ID="$(node -e 'console.log(require("crypto").randomUUID())')"
  fi
  cat >"$SETTINGS_FILE" <<EOF_SETTINGS
{
  "onboardingCompleted": true,
  "machineId": "$MACHINE_ID"
}
EOF_SETTINGS
  echo "[entrypoint] Created settings.json with generated machineId at $SETTINGS_FILE"
fi

if [ ! -f "$ACCESS_KEY_FILE" ]; then
  # Check if we have a TTY attached or if interactive mode is forced
  if [ -t 0 ]; then
    exec node /app/bin/happy.mjs "$@"
  else
    cat >&2 <<EOF_ERROR
[entrypoint] Missing credentials file: $ACCESS_KEY_FILE
[entrypoint] The daemon needs an access key to connect to Happy Server.
[entrypoint] Run the container interactively to obtain new credentials.

[entrypoint] Example with docker run:
  docker run -it --rm \\
    -v happy-data:$HAPPY_HOME \\
    happy-daemon

[entrypoint] Example with docker compose:
  docker compose run --rm happy-daemon
EOF_ERROR
    exit 1
  fi
fi

exec "$@"
