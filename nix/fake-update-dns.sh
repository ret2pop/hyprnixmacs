#!/bin/sh
export CLOUDFLARE_TOKEN="$(cat /run/user/1000/secrets/cloudflare-dns | tr -d '\n')"
poetry run octodns-sync --config-file result
