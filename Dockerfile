FROM ubuntu:24.04

ARG TARGETARCH
ARG RELEASE_URL_AMD64
ARG RELEASE_URL_ARM64

ENV TZ=Asia/Hong_Kong

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl jq libicu74 libsqlite3-0 libstdc++6 sqlite3 tar tzdata unzip zlib1g \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    case "$TARGETARCH" in \
      amd64) release_url="$RELEASE_URL_AMD64" ;; \
      arm64) release_url="$RELEASE_URL_ARM64" ;; \
      *) echo "Unsupported architecture: $TARGETARCH" >&2; exit 1 ;; \
    esac; \
    test -n "$release_url"; \
    mkdir -p /tmp/release /app; \
    curl --fail --location --retry 3 "$release_url" --output /tmp/dice-next.tar.gz; \
    tar -xzf /tmp/dice-next.tar.gz -C /tmp/release; \
    test -d /tmp/release/DiceNext-beta; \
    cp -a /tmp/release/DiceNext-beta/. /app/; \
    mkdir -p /app-seed; \
    cp -a /app/data /app-seed/data; \
    rm -rf /tmp/release /tmp/dice-next.tar.gz; \
    chmod +x /app/dice-next-server /app/start.sh

WORKDIR /app

COPY docker-entrypoint.sh configure-napcat.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/dice-next-entrypoint /usr/local/bin/configure-napcat.sh

EXPOSE 18088

ENTRYPOINT ["/usr/local/bin/dice-next-entrypoint"]
