#!/usr/bin/env sh
set -eu

CONFIG_FILE=/app/config/default_config.json
DATABASE_FILE=/app/data/dice.db

log_info() {
    printf '%s\n' "[dice-next] $*"
}

if [ "${MODE:-}" != "napcat" ]; then
    exit 0
fi

log_info 'MODE=napcat: configuring the QQ OneBot adapter for reverse WebSocket port 3002.'

mkdir -p "$(dirname "$CONFIG_FILE")"

# Dice!Next imports this file only when its adapter table is empty. Keep it in
# sync with the runtime database so a new and an existing installation behave
# the same way.
if [ ! -f "$CONFIG_FILE" ]; then
    printf '%s\n' '{"adapters":[]}' > "$CONFIG_FILE"
fi

CONFIG_TMP="${CONFIG_FILE}.napcat.tmp"
jq '
  (.adapters // []) as $adapters
  | ($adapters | map(select(.type == "onebot_v11"))) as $qqAdapters
  | ($qqAdapters[0] // {}) as $previous
  | .adapters = (
      ($adapters | map(select(.type != "onebot_v11")))
      + [($previous + {
          "id": ($previous.id // "adapter-napcat-reverse"),
          "name": ($previous.name // "NapCat"),
          "type": "onebot_v11",
          "connection_mode": "reverse_ws",
          "endpoint": "3002",
          "access_token": "",
          "enabled": true
        })]
    )
' "$CONFIG_FILE" > "$CONFIG_TMP"

if ! cmp -s "$CONFIG_FILE" "$CONFIG_TMP"; then
    if [ ! -f "${CONFIG_FILE}.pre-napcat" ]; then
        cp "$CONFIG_FILE" "${CONFIG_FILE}.pre-napcat"
    fi
    mv "$CONFIG_TMP" "$CONFIG_FILE"
    log_info "Updated $CONFIG_FILE."
else
    rm -f "$CONFIG_TMP"
fi

# Existing installations load adapters from data/dice.db rather than from the
# JSON file. One reverse listener owns port 3002, so retain one QQ/OneBot row
# exactly as the previous Docker implementation retained one QQ endpoint.
if [ -f "$DATABASE_FILE" ]; then
    has_table="$(sqlite3 "$DATABASE_FILE" "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='adapters';")"
    if [ "$has_table" = "1" ]; then
        onebot_count="$(sqlite3 "$DATABASE_FILE" "SELECT COUNT(*) FROM adapters WHERE type = 1;")"
        canonical_count="$(sqlite3 "$DATABASE_FILE" "SELECT COUNT(*) FROM adapters WHERE type = 1 AND connection_mode = 1 AND endpoint = '3002' AND access_token = '' AND enabled = 1;")"
        if [ "$onebot_count" != "1" ] || [ "$canonical_count" != "1" ]; then
            if [ ! -f "${DATABASE_FILE}.pre-napcat" ]; then
                cp "$DATABASE_FILE" "${DATABASE_FILE}.pre-napcat"
            fi
            sqlite3 "$DATABASE_FILE" <<'SQL'
BEGIN IMMEDIATE;
DELETE FROM adapters WHERE type = 1;
INSERT INTO adapters (name, type, connection_mode, endpoint, access_token, enabled, config)
VALUES ('NapCat', 1, 1, '3002', '', 1, '{}');
COMMIT;
SQL
            log_info "Updated QQ OneBot adapter in $DATABASE_FILE."
        fi
    fi
fi

log_info 'NapCat reverse WebSocket configuration is ready.'
