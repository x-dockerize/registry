#!/usr/bin/env bash
set -e

ENV_EXAMPLE=".env.example"
ENV_FILE=".env"

# --------------------------------------------------
# Kontroller
# --------------------------------------------------
if [ ! -f "$ENV_EXAMPLE" ]; then
  echo "❌ $ENV_EXAMPLE bulunamadı."
  exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
  cp "$ENV_EXAMPLE" "$ENV_FILE"
  echo "✅ $ENV_EXAMPLE → $ENV_FILE kopyalandı"
else
  echo "ℹ️  $ENV_FILE mevcut, güncellenecek"
fi

# --------------------------------------------------
# Yardımcı Fonksiyonlar
# --------------------------------------------------
set_env() {
  local key="$1"
  local value="$2"

  if grep -q "^${key}=" "$ENV_FILE"; then
    sed -i "s|^${key}=.*|${key}=${value}|" "$ENV_FILE"
  else
    echo "${key}=${value}" >> "$ENV_FILE"
  fi
}

# --------------------------------------------------
# Kullanıcıdan Gerekli Bilgiler
# --------------------------------------------------
read -rp "REGISTRY_HOSTNAME (örn: registry.example.com): " REGISTRY_HOSTNAME

echo
read -rp "Kullanıcı adı: " REGISTRY_USERNAME
read -rsp "Şifre: " REGISTRY_PASSWORD
echo

# --------------------------------------------------
# htpasswd Oluştur
# --------------------------------------------------
mkdir -p ".docker/registry/auth"
docker run --rm httpd:2-alpine htpasswd -nbB "$REGISTRY_USERNAME" "$REGISTRY_PASSWORD" \
  > ".docker/registry/auth/htpasswd"
echo "✅ htpasswd oluşturuldu"

# --------------------------------------------------
# .env Güncelle
# --------------------------------------------------
set_env REGISTRY_HOSTNAME "$REGISTRY_HOSTNAME"

# --------------------------------------------------
# Sonuçları Göster
# --------------------------------------------------
echo
echo "==============================================="
echo "✅ Registry .env başarıyla hazırlandı!"
echo "-----------------------------------------------"
echo "🌐 URL  : https://$REGISTRY_HOSTNAME"
echo "👤 User : $REGISTRY_USERNAME"
echo "-----------------------------------------------"
echo "Servisi başlatmak için:"
echo "  docker compose -f docker-compose.production.yml up -d"
echo "==============================================="
