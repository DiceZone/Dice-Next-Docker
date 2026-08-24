#!/usr/bin/env sh
set -eu

# Bind mounts start empty on first use. Add bundled resources that are absent
# from the host directory without overwriting user plugins, rulepacks, or logs.
mkdir -p /app/data
cp -an /app-seed/data/. /app/data/

case "${MODE:-}" in
    napcat)
        /usr/local/bin/configure-napcat.sh
        ;;
    diceflats)
        # BDC 公寓模式由节点 daemon 使用实例自己的 X-API-Key 调用正式 API
        # 完成配置。这里不改 JSON/SQLite，也不把业务密钥塞进 Compose。
        ;;
esac

exec /app/start.sh "$@"
