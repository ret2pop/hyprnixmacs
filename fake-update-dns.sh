#!/bin/sh
SECRET_FILE="${CLOUDFLARE_SECRET_PATH:-/run/user/1000/secrets/cloudflare-dns}"

if [ ! -f "$SECRET_FILE" ]; then
    echo "Error: Cloudflare DNS token file not found at $SECRET_FILE" >&2
    exit 1
fi

export CLOUDFLARE_TOKEN="$(cat "$SECRET_FILE" | tr -d '\n')"
poetry run octodns-sync --config-file result
