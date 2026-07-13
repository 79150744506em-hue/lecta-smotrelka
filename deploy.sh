#!/usr/bin/env bash
# Ручной деплой в Yandex Object Storage.
# Перед первым запуском: aws configure  (введи свои Access Key ID / Secret от сервисного аккаунта)
# Запуск:  YC_BUCKET=имя-бакета ./deploy.sh
set -euo pipefail

BUCKET="${YC_BUCKET:-smotrelka}"
EP="https://storage.yandexcloud.net"
# Yandex Object Storage не принимает новые CRC-чек-суммы AWS CLI v2.23+ — отключаем
export AWS_REQUEST_CHECKSUM_CALCULATION=WHEN_REQUIRED
export AWS_RESPONSE_CHECKSUM_VALIDATION=WHEN_REQUIRED

echo "→ Синхронизирую ассеты в s3://$BUCKET ..."
aws s3 sync . "s3://$BUCKET" --endpoint-url "$EP" --delete \
  --cache-control "public, max-age=86400" \
  --exclude ".git/*" --exclude ".github/*" --exclude ".claude/*" \
  --exclude ".gitignore" --exclude "README.md" --exclude "DEPLOY.md" \
  --exclude "deploy.sh" --exclude "*.DS_Store" --exclude "*.html"

echo "→ Синхронизирую HTML (no-cache) ..."
aws s3 sync . "s3://$BUCKET" --endpoint-url "$EP" \
  --cache-control "no-cache" --content-type "text/html; charset=utf-8" \
  --exclude "*" --include "*.html" \
  --exclude ".git/*" --exclude ".github/*" --exclude ".claude/*"

echo "✅ Готово: http://$BUCKET.website.yandexcloud.net"
