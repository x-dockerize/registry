#!/usr/bin/env bash
set -e

HTPASSWD_FILE=".docker/registry/auth/htpasswd"

if [ ! -f "$HTPASSWD_FILE" ]; then
  echo "❌ $HTPASSWD_FILE bulunamadı. Önce install.sh çalıştırın."
  exit 1
fi

read -rp "Kullanıcı adı: " USERNAME
read -rsp "Şifre: " PASSWORD
echo

docker run --rm httpd:2-alpine htpasswd -nbB "$USERNAME" "$PASSWORD" >> "$HTPASSWD_FILE"
echo "✅ Kullanıcı eklendi: $USERNAME"
echo "ℹ️  Registry yeniden başlatılmasına gerek yok — değişiklikler anında aktif."
