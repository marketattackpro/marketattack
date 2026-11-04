# MONITOREO — quién vigila qué

## Dos vigilantes

| Vigilante | Cada | Qué revisa | Cómo avisa |
|---|---|---|---|
| **Dentro del VPS** (`watchdog_marketattack.sh`) | 5 min | nginx, chat, bot, páginas, tiendas de clientes, certificado y disco | Telegram al celular |
| **Fuera del VPS** (GitHub Actions) | 10 min | que el sitio abra desde internet | Correo de GitHub + aviso en el repositorio |

El de adentro repara solo lo que puede (reinicia servicios, republica páginas).
El de afuera sirve para saber si se cayó **todo el servidor o la red**.

## Qué llega al celular

- 🚨 **Problema detectado**: un servicio no arranca, una página no responde,
  el certificado está por vencer o el disco se llenó.
  - Mientras siga el problema, se repite **cada 30 minutos** (no cada 5).
- ✅ **Todo normal**: cuando el problema se resolvió.

Si no quieres que te repita, se ajusta el tiempo en el archivo del vigilante.

## Qué hacer cuando llega un 🚨

1. Abre el sitio: https://marketattack.duckdns.org
2. Si abre bien, fue un aviso pasajero: no hagas nada.
3. Si no abre:
   - Entra al VPS y mira el registro:
     `sudo tail -50 /var/log/marketattack_watchdog.log`
   - Reinicia el servicio que diga el aviso:
     `sudo systemctl restart nginx` (o el que sea).
4. Si no puedes entrar al VPS, avísame: se restaura desde el último respaldo.

## Aviso externo por GitHub

- Archivo: `.github/workflows/vigilancia_externa.yml`
- Si el sitio no responde, abre un aviso titulado
  **“🚨 MARKETATTACK no responde”** en el repositorio y GitHub manda correo.
- Cuando vuelve, el aviso se cierra solo.
- Para probarlo a mano: repositorio → pestaña **Actions** → **Vigilancia
  externa** → **Run workflow**.

## Opcional: aviso al celular desde fuera (recomendado con clientes)

GitHub manda correo, pero el celular es más rápido. UptimeRobot es gratis:

1. Entra a https://uptimerobot.com y crea la cuenta con
   `marketattackpro@gmail.com` (confirma el correo).
2. **Add New Monitor**:
   - Type: `HTTPS`
   - Name: `MARKETATTACK`
   - URL: `https://marketattack.duckdns.org/`
   - Interval: `5 minutes`
3. En **Alert Contacts**, conecta Telegram (te da un botón para abrir el bot
   de UptimeRobot y darle *Start*).
4. Guarda. Listo: si el sitio se cae, llega push al celular.

Se hace una sola vez y no cuesta nada. Yo no puedo crear la cuenta porque el
registro pide confirmar el correo del proyecto.
