#!/usr/bin/env bash
set -euo pipefail

if [ ! -f .env ]; then
  echo "[ERROR] .env ファイルが見つかりません。"
  echo "  cp .env.example .env  を実行して値を設定してください。"
  exit 1
fi

exec npx --yes dotenv-cli -e .env -- claude "$@"
