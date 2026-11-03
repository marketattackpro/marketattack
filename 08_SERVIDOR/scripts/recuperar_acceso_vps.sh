#!/bin/bash
# ============================================================
#  MARKETATTACK - Recuperar acceso SSH al VPS
#  Se ejecuta DENTRO de Oracle Cloud Shell (no en el equipo).
#  Agrega la llave publica de this PC al usuario ubuntu del VPS.
# ============================================================
set -e

export OCI_CLI_REGION=sa-bogota-1
INSTANCE="ocid1.instance.oc1.sa-bogota-1.anrgcljrgzt7d3yc7s7ad5uw3zy4itucruzbw4hs6cngdwfzwkscivkm64tq"
PUBKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ0oS5AHOMCjRQC9m23MdR0KVY4aYJP2Ocf/Dp+Z7ENu jarvisnet@jarvisnet-desktop"

echo "1) Buscando el compartimento de la instancia..."
COMP=$(oci compute instance get --instance-id "$INSTANCE" \
        --query 'data."compartment-id"' --raw-output)
echo "   compartimento: $COMP"

echo "2) Preparando el comando que se ejecutara en el VPS..."
CONTENT=$(printf 'mkdir -p /home/ubuntu/.ssh; grep -qF "%s" /home/ubuntu/.ssh/authorized_keys 2>/dev/null || echo "%s" >> /home/ubuntu/.ssh/authorized_keys; chown -R ubuntu:ubuntu /home/ubuntu/.ssh; chmod 700 /home/ubuntu/.ssh; chmod 600 /home/ubuntu/.ssh/authorized_keys; echo LLAVE_AGREGADA_OK' "$PUBKEY" "$PUBKEY")

JSON=$(python3 -c 'import json,sys; print(json.dumps({"source":{"sourceType":"TEXT","text":sys.argv[1]},"output":{"outputType":"TEXT"}}))' "$CONTENT")

echo "== Comprobando el agente de Oracle (plugin de comandos) =="
PLUG=$(oci compute instance-agent-plugin list \
  --compartment-id "$COMP" --instanceagent-id "$INSTANCE" \
  --query 'data[?contains("name", `Run Command`)].{n:name,s:status}' --output table 2>/dev/null)
echo "$PLUG"
echo "$PLUG" | grep -qi "ENABLED" || {
  echo "!! El plugin 'Compute Instance Run Command' NO esta activo."
  echo "   Solucion rapida: en la consola de Oracle ->"
  echo "   Instancias -> marketattack -> pestana 'Oracle Cloud Agent' ->"
  echo "   activa 'Compute Instance Run Command' y vuelve a correr este script."
  exit 1
}

echo "== Enviando la orden al servidor =="
oci instance-agent command create \
  --compartment-id "$COMP" \
  --target "{\"instanceId\":\"$INSTANCE\"}" \
  --command-content "$JSON" \
  --display-name "add-marketattack-key" \
  --wait-for-state SUCCEEDED --wait-interval-seconds 5

echo
echo "== Listo. Si dice SUCCEEDED y LLAVE_AGREGADA_OK, ya podemos entrar desde la PC. =="
