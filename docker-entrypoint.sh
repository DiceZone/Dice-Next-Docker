#!/usr/bin/env sh
set -eu

# Bind mounts start empty on first use. Add bundled resources that are absent
# from the host directory without overwriting user plugins, rulepacks, or logs.
mkdir -p /app/data
cp -an /app-seed/data/. /app/data/

if [ "${MODE:-}" = "napcat" ]; then
    /usr/local/bin/configure-napcat.sh
fi

exec /app/start.sh "$@"
