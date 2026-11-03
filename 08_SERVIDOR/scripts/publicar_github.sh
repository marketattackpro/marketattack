#!/bin/bash
# ═══════════════════════════════════════════════════════════
#  ESPEJO AUTOMÁTICO EN GITHUB (para no depender de la PC)
#
#  Sube al repositorio una copia del último respaldo íntegro:
#    - 08_SERVIDOR/scripts   (programas del servidor)
#    - 08_SERVIDOR/config    (configuración saneada)
#    - 08_SERVIDOR/web       (la web publicada)
#    - 08_SERVIDOR/ESTADO.txt y SHA256SUMS
#
#  Requisitos (una sola vez, ya hecho):
#    llave /root/.ssh/id_ed25519 autorizada como deploy key
#    con "Allow write access" en marketattackpro/marketattack.
#
#  Seguridad: si detecta algo con pinta de secreto, NO publica.
# ═══════════════════════════════════════════════════════════
REPO=/root/marketattack-git
ORIGEN=/var/backups/marketattack/completos
REMOTO=git@github.com:marketattackpro/marketattack.git
DESTINO=08_SERVIDOR

echo "→ espejo en GitHub"

if ! sudo test -f /root/.ssh/id_ed25519; then
  echo "  ℹ el VPS todavía no tiene llave de GitHub."
  echo "    Se deja constancia del estado en el VPS: $REPO"
  exit 0
fi
# OJO: GitHub responde "autenticado" pero ssh sale con error (no da shell).
# Por eso se comprueba el mensaje, no el código de salida.
AUTH=$(sudo ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 || true)
case "$AUTH" in
  *"successfully authenticated"*) : ;;
  *)
    echo "  ⚠ la llave existe pero GitHub no la acepta."
    echo "    Añádela como deploy key con permiso de escritura en el repositorio."
    exit 0
    ;;
esac

# reconstruir desde el último respaldo íntegro
ult=$(sudo find "$ORIGEN" -name 'completo_*.tar.gz' | sort -r | head -1)
[ -z "$ult" ] && { echo "  ✗ no hay respaldos en $ORIGEN"; exit 1; }
echo "  fuente: $(basename "$ult")"

sudo rm -rf /tmp/pub && sudo mkdir -p /tmp/pub
sudo tar -xzf "$ult" -C /tmp/pub || { echo "  ✗ no se pudo abrir el respaldo"; exit 1; }

# ── seguridad: nunca subir secretos a un repositorio público ──
PATRON='gsk_[A-Za-z0-9]{20,}|-----BEGIN [A-Z ]*PRIVATE KEY-----|TELEGRAM_TOKEN=[0-9]{6,}|OPENCODE_SERVER_PASSWORD=[A-Za-z0-9]'
fugas=$(sudo grep -rIlE -- "$PATRON" /tmp/pub/contenido 2>/dev/null | head -5)
if [ -n "$fugas" ]; then
  echo "  ✗ posibles secretos detectados; NO se publica:"
  echo "$fugas" | sed 's#/tmp/pub/contenido/#      #'
  exit 0
fi

# ── preparar el repositorio ANTES de copiar (si no, se borraría) ──
if sudo git ls-remote "$REMOTO" >/dev/null 2>&1; then
  if [ ! -d "$REPO/.git" ]; then
    echo "  · clonando el repo desde GitHub"
    sudo rm -rf "$REPO"
    sudo git clone -q --branch main "$REMOTO" "$REPO" 2>/dev/null || sudo git clone -q "$REMOTO" "$REPO"
  fi
else
  [ -d "$REPO/.git" ] || sudo git init -q -b main "$REPO"
fi

# ── copiar el contenido del respaldo (sin borrar archivos del repo) ──
sudo mkdir -p "$REPO/$DESTINO"
for d in scripts config web; do
  if [ -d "/tmp/pub/contenido/$d" ]; then
    sudo mkdir -p "$REPO/$DESTINO/$d"
    sudo rsync -a "/tmp/pub/contenido/$d/" "$REPO/$DESTINO/$d/"
  fi
done
sudo cp /tmp/pub/ESTADO.txt "$REPO/$DESTINO/ESTADO.txt" 2>/dev/null
sudo cp /tmp/pub/SHA256SUMS "$REPO/$DESTINO/SHA256SUMS" 2>/dev/null

export GIT_SSH_COMMAND="ssh -i /root/.ssh/id_ed25519 -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"

sudo bash -c "
  export GIT_SSH_COMMAND='ssh -i /root/.ssh/id_ed25519 -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new'
  cd '$REPO' || exit 1
  git config user.email 'vps@marketattack.local'
  git config user.name 'MARKETATTACK VPS'
  git config core.safecrlf false
  git remote set-url origin '$REMOTO'
  git checkout -q -B main
  # si alguien subió cambios a GitHub (por ejemplo, un workflow), traerlos antes
  if git fetch -q origin main 2>/dev/null; then
    if ! git rebase -q origin/main 2>/dev/null; then git rebase --abort 2>/dev/null; fi
  fi
  # nunca borrar el .gitignore del repositorio: solo añadir lo que falte
  for p in '*.db' '*.zip' '*.tar.gz' '*.key' '*.pem' '.env'; do
    grep -qxF \"\$p\" .gitignore 2>/dev/null || printf '%s\n' \"\$p\" >> .gitignore
  done
  git add -A 2>/dev/null
  if git diff --cached --quiet; then echo '  sin cambios nuevos'; exit 0; fi
  git commit -q -m \"respaldo automático del VPS $(date '+%Y-%m-%d %H:%M')\"
  if git push -q origin main; then
    echo '  ✓ empujado a GitHub (rama main)'
  else
    # segundo intento: sincronizar con lo que haya en GitHub y volver a subir
    if git fetch -q origin main 2>/dev/null && git rebase -q origin/main 2>/dev/null && git push -q origin main; then
      echo '  ✓ empujado a GitHub (rama main, tras sincronizar)'
    else
      git rebase --abort 2>/dev/null || true
      echo '  ✗ no se pudo empujar'
    fi
  fi
" || echo "  ⚠ el espejo no se pudo actualizar"

sudo rm -rf /tmp/pub
