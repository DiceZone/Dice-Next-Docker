FROM ubuntu:24.04

ARG TARGETARCH
ARG RELEASE_URL_AMD64
ARG RELEASE_URL_ARM64

ENV TZ=Asia/Hong_Kong

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl libicu74 libsqlite3-0 libstdc++6 tar tzdata unzip zlib1g \
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
    rm -rf /tmp/release /tmp/dice-next.tar.gz; \
    chmod +x /app/dice-next-server /app/start.sh

WORKDIR /app

# Named volumes are initialized from the image on first use and retain the
# bot configuration and data across container replacements.
VOLUME ["/app/config", "/app/data"]

EXPOSE 18088

ENTRYPOINT ["/app/start.sh"]
