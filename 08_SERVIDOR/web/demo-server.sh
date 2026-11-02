#!/usr/bin/env bash
# =========================================================================
# MARKETATTACK — Servidor local para ver la demo desde PC o celular
# Uso:  ./demo-server.sh   (o sin el ./:  bash demo-server.sh)
# Detener: Ctrl+C
# =========================================================================
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
PUERTO=8000

cd "$DIR"

# Detectar la IP local de la máquina en la red
IP=$(hostname -I 2>/dev/null | awk '{print $1}')
if [ -z "$IP" ]; then
  IP="192.168.1.x"
fi

echo "=========================================================="
echo "  MARKETATTACK · Demo IA"
echo "----------------------------------------------------------"
echo "  Desde este PC:   http://localhost:$PUERTO"
echo "  Desde el móvil:  http://$IP:$PUERTO"
echo ""
echo "  (Conecta tu celular a la MISMA red Wi-Fi que este PC)"
echo "  Para detener el servidor: Ctrl+C"
echo "=========================================================="

python3 -m http.server "$PUERTO"