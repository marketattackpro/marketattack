# CONTEXTO.md — MARKETATTACK · ESTADO DEL PROYECTO (memoria portable)
# ▸ Pega ESTE archivo + la carpeta 02_DEMO a CUALQUIER PC/dispositivo,
#   ábreme ahí y dime: «lee /ruta/CONTEXTO.md» → retomo TODO sin perder nada.
# ▸ Última actualización: 2026-09-18
# ▸ REGLA BLINDADA: cada avance aprobado = 1 zip en 05_RESPALDOS/. El motor
#   (02_DEMO) JAMÁS se toca: por cliente solo cambia config_cliente.js.

## ── [1] QUÉ ES ESTO ──────────────────────────────────────────────
Tienda digital autocontenida (1 solo archivo HTML + assets) que el proveedor
cliente comparte como LINK público: tus clientes ven productos → CARITO →
pedido confirmado por WHATSAPP (el Nº del CLIENTE recibe pedidos). Programado
para crecer orgánico GRATIS ($0/mes, sin membresías): PC local + GitHub +
Netlify + Bitly + QR.

## ── [2] ESTRUCTURA REAL (verificada en /mnt/proyectos/04_MARKETATTACK/) ──
- 01_DOCUMENTACION/
- 02_DEMO/tienda.html + assets/(carrito.js, tienda_autocontenida.html, demo.js)
- 05_RESPALDOS/           ← respaldo zip de CADA avance aprobado (regla)
- 05_CLIENTES/<cliente>/config_cliente.js + RESPALDOS/  ← 1 carpeta por cliente
- 06_DIFUSION/            ← QR + textos listos-para-pegar
- 08_CLIENTES/ (o según lo ya creado)

## ── [3] LINKS VIVOS (verificados 200 en vivo, no prometidos) ──────
- LOCAL (tu PC):        http://localhost:8000/tienda.html
- PÚBLICO netlify.app:  https://marketattack.netlify.app/        ← EL LIMPIO, el del QR
- QR generado:          /05_EXPANSION/... / QR_tienda_marketattack.png
- GitHub repo público:  github.com/gtcorebynet-jpg/marketattack
  (raw sirve 200; HTMLPreview funcional si se necesita)

## ── [4] LOG DE AVANCES APROBADOS (línea por avance) ──────────────
- [2026-09-12] Demo 02_DEMO servida local :8000 (200) + respaldo zip inicial.
- [2026-09-12] Web «tienda_autocontenida» publicada (htmlpreview 200) + QR.
- [2026-09-18] Kit difusión (QR + textos listos-para-pegar) creado y respaldado.
- [2026-09-18] Netlify publicado: marketattack.netlify.app → 200 (ambas rutas).
- [2026-09-18] QR regenerado apuntando al link LIMPIO .netlify.app (escaneo OK usuario).
- [2026-09-25] Botones carrito/WhatsApp separados · servidor local relanzado (200).
- [2026-09-25] FASE 1 ✓ Kit de Rescate en 07_KIT_RESCATE/ (guía + restaurar.sh +
  chat exportado opencode.db + config + respaldo_automatico.sh + secretos.EJEMPLO).
  Zip portable: 05_RESPALDOS/KIT_RESCATE_2026-09-25_2338.zip
- [2026-09-25] FASE 2 ✓ Respaldo total subido a repo PRIVADO
  github.com/gtcorebynet-jpg/marketattack-respaldo  (verificado 404 = privado).
- [2026-09-26] FASE 3 ✓ VPS Oracle (157.137.203.223) — acceso SSH con llave
  `~/Descargas/ssh-key-2026-09-26.key`, usuario `ubuntu`, Ubuntu 24.04 (15GB/45GB/2CPU).
  · nginx instalado y sirviendo /var/www/marketattack (verificado 200 en
    /, /tienda.html, /assets/carrito.js)
  · iptables corregido: 80/443/22 aceptados ANTES de la regla REJECT + persistido
  · cron: backup diario 3:00 AM (/var/backups/marketattack) + watchdog cada 5 min
    que reinicia nginx si la web cae (/var/log/marketattack_watchdog.log)
  · nginx enabled al arrancar
  ✓ PUERTOS ABIERTOS (resuelto 2026-09-26): en "Default Security List for
    vcn-20260924-1640" → Reglas de entrada se agregaron 80 y 443 (TCP, 0.0.0.0/0).
  ✓ VERIFICADO DESDE INTERNET: http://157.137.203.223/ = 200,
    /tienda.html = 200, /assets/carrito.js = 200 (probado desde el celular con datos).
  → El VPS ya es un hosting propio y público. 2o link público del proyecto.

- [2026-09-26] PENDIENTES CERRADOS (pasos 4 y 5) ✓
  · Paso 5: servidor local http://localhost:8000/tienda.html → 200.
    Launcher permanente: 02_DEMO/encender_web.sh (tras reiniciar la PC).
  · Paso 4: LLAVE SSH ROTADA. Nueva: ~/Descargas/ssh-key-marketattack-20260926.key
    (probada, conecta OK). Vieja (ssh-key-2026-09-26.key) sigue en authorized_keys
    para no perder acceso → se elimina en Oracle cuando el usuario lo decida.

- [2026-09-26] FASE 4 · TELEGRAM — INSTALADO, SOLO FALTA ACTIVAR
  · /usr/local/bin/aviso_telegram.sh (envía alertas)
  · watchdog (cada 5 min) avisa si la web CAE y cuando se RECUPERA
  · /usr/local/bin/informe_diario.sh (8:00 AM): estado, disco, RAM, último backup
  · crons activos: 3:00 AM backup · cada 5 min watchdog · 8:00 AM informe
  · ACTIVAR: editar /etc/marketattack/telegram.conf y poner 2 datos de @BotFather:
      TELEGRAM_TOKEN="123456:ABC..."      TELEGRAM_CHAT_ID="987654321"
    (después: chmod 600 y probar con /usr/local/bin/informe_diario.sh)


## ── [4b] CÓMO RECUPERAR TODO EN OTRA PC (el "1 clic") ─────────────
1. Instalar opencode.
2. Clonar/descargar el repo privado marketattack-respaldo (o el ZIP del kit).
3. Descomprimir → `bash restaurar.sh` → restaura proyecto + config + chat.
4. Abrir opencode en la carpeta MARKETATTACK → ver la conversación.
5. Decirme: "lee CONTEXTO.md" → retomo aquí.


## ── [5] SIGUIENTE PASO PENDIENTE ─────────────────────────────────
- PRIMER CLIENTE REAL: pedirle nombre, rubro, zona, promo y SU Nº WhatsApp.
- Al recibirlo → generar su config_cliente.js + su respaldo zip + su QR propio.
- Siguiente avance con Netlify/bit.ly link corto (requiere SU sesión/token una vez).

## ── [6] CÓMO LEVANTAR TODO EN OTRO DISPOSITIVO (memoria portable) ──
1. Copia la carpeta del proyecto (o haz git clone/pull del repo público).
2. Asegura que CONTEXTO.md este junto a 02_DEMO/.
3. Ejecútame ahí y di: «lee /ruta/CONTEXTO.md» → listo, mismo contexto.
4. (Opcional) exporta esta conversación (tema: MARKETATTACK) como historial en texto
   y pásala igual: así conservamos TAMBIÉN el diálogo fino (decisiones, tu tono).

## ── [7] CREDENCIALES / SESIONES (honestidad: qué necesita TU sesión) ─
GitHub, Netlify, Bitly exigen TU autenticación la 1.ª vez (sesión o token) —
ningún agente puede generarla por ti SIN tu token. Verificado, no supuesto.
- Hazlo tú en 15 s (drag en Netlify Drop / token la primera vez), o
- Pégame TU token seguro y lo hace el agente (sin imprimirlo).

## ── [8] DECISIONES DE TONO (para conversación consistente) ────────
- Verdad medida, verificado-contigo (200/200/200), nunca links «prometidos».
- Respaldo CADA avance; el motor no se toca; práctico y breve.
- Crecimiento orgánico: solo herramientas con plan GRATIS inicial ($0).

---

## 2026-09-28 · Servicio de tiendas para clientes +/endurecimiento

### Nuevo: crear tiendas con datos por Telegram
El usuario manda los datos del cliente al bot y el servidor genera la web
completa (productos, WhatsApp, QR) y devuelve el link.

```
/cliente
Nombre: Tienda Don Pepe
WhatsApp: 573001234567
Tagline: Los mejores arepas
Horario: Lun-Sab 8am-8pm
Zona: Soacha
1. Arepa con pollo | 12000 | Pollo y queso
2. Jugo de mango | 5000 | Natural
```
Responde con el link `http://157.137.203.223/clientes/<slug>/tienda.html`
y manda el QR como foto.

Comandos: `/cliente` `/clientes` `/estado` `/respaldos` `/publicar`
`/backup` `/link` `/qr` `/leer` `/nueva` `/ayuda`

### Herramientas
| Script | Para qué |
|---|---|
| `nuevo_cliente.py` | genera la tienda de un cliente |
| `verificar_tienda.sh` | audita web + datos + WhatsApp + QR de verdad |
| `puente_telegram.py` | puente Telegram → opencode |

### Bug corregido: 200 engañoso
nginx tenía `try_files ... /index.html`, así que **toda** ruta inexistente
devolvía 200 con la portada. Ahora es `try_files ... =404`.
`nuevo_cliente.py` tampoco se fía del 200: comprueba que la página
realmente contenga los datos del cliente y que el QR sea un PNG válido.

### Watchdog v2 (antes solo miraba nginx)
Cada 5 minutos revisa: nginx, opencode, puente de Telegram, las 3 páginas
principales, **todas las tiendas de clientes** y el espacio en disco.
Si algo cae lo reinicia; si una página cae, re-publica.
Probado matando los 3 servicios: los levantó todos.

### Informe diario a Telegram
A las 8:00 AM llega el estado: páginas, servicios, número de tiendas,
respaldos, disco, RAM y resultado de la auditoría.

### Seguridad
- Llave SSH **vieja eliminada** del servidor (estuvo pegada en el chat).
  Quedan 2: `marketattack-nueva-20260926` (PC) y `telefono` (Android, solo túnel).
- Copia: `/home/ubuntu/.ssh/authorized_keys.bak-2026*`
- Backups con cron + el paquete del cliente se respaldan antes de publicar.
- `opencode` y el token del bot solo se leen desde el servidor, nunca se mandan.

### Android / Termux
El puerto 4096 **no** se abre a internet. Acceso por túnel:
```bash
ssh -N -L 4096:localhost:4096 -i ~/.ssh/ma_celular ubuntu@157.137.203.223
```
Luego, en Chrome del celular:
```
http://opencode:<CLAVE>@127.0.0.1:4096/
```
La clave va en la URL porque sin ella el servidor responde **401 con cuerpo
vacío** (por eso se veía en blanco).
El binario oficial ARM64 pide musl + libstdc++ que Termux no trae; la vía que
funciona es el tarball `opencode-linux-arm64-musl`.

---

## 2026-10-06 — Comandos por Telegram + respaldos redundantes

### Rotación de seguridad (hecho)
- Llave SSH de la PC activa: `ssh-key-marketattack-20260926.key`
  (huella `SHA256:VbRrdAfJiujLH/aNxcyjKtOBxrcvcJXbMSlqqLpspvo`).
  La llave antigua se quitó de `authorized_keys`.
- Llave del celular (`telefono`) restringida al túnel del puerto 4096:
  `SHA256:9lI9c4iGJDIgw2av5ud6a7azsVBUgwA4XhzdlVgCcnw`.
- **Clave de opencode rotada.** La antigua ya no sirve (401).
  Se guarda solo en el servidor: `sudo cat /root/CLAVE_OPENCODE.txt` (root, 600).
  **Nunca** escribirla en este archivo, en Telegram ni en GitHub.
- Las claves ya usadas se listan en `/etc/marketattack/claves_rotadas.txt`
  (600) y el exportador del chat las borra automáticamente.

### Comandos desde Telegram (nuevo)
El puente responde a:
- `/comandos` — lista lo que puede hacer.
- `/sh <comando>` — ejecuta y devuelve la salida. Lista blanca:
  `ls cat head tail grep find wc du df free uptime date uname whoami hostname
  id ps stat echo which file sed tree realpath md5sum verificar_tienda.sh
  backup_marketattack.sh publicar.sh qr_tienda.py nuevo_cliente.py
  exportar_sesion.py nginx python3 node opencode crontab env`
- `/reiniciar nginx|opencode|puente-telegram` — solo esos tres.

Lo destructivo está **bloqueado a propósito**: `rm`, `chmod`, `dd`, `wget`,
`kill`, `apt`, `curl -X`, `shutdown`, etc. se rechazan con un mensaje que
explica qué sí se puede hacer. Hay 22 pruebas automáticas que cubren
estos casos.

### Respaldo en 4 vías (nuevo)
| Vía | Qué guarda | Dónde | Cuándo |
|-----|-----------|-------|--------|
| A — VPS disco | chat + web + scripts + config saneada | `/var/backups/marketattack/completos/` | 02:30 diario, 14 días |
| B — VPS espejo | copia idéntica de A | `/root/marketattack-rescate/` | 02:30 diario, 14 días |
| C — Telegram | kit con contexto + chat + scripts | el chat, 00:00 diario | 00:00 diario, 30 kits |
| D — GitHub | código, contexto, config saneada | `gtcorebynet-jpg/marketattack` | al guardar cambios |

- Cada respaldo lleva `SHA256SUMS`: si algo se corrompe, se nota.
- `verificar_respaldos.sh` revisa **las dos vías** y comprueba que coincidan.
  Probado con dos fallos reales: archivo truncado y archivo manipulado.
  Ambos detectados.
- La copia del chat se hace con `sqlite3.backup()` (copia consistente
  aunque la base esté en uso), no con `cp`.

### Restaurar desde cualquier sitio
`recuperar.sh` permite elegir de dónde:
- `recuperar.sh A` — desde el ZIP de Telegram (el celu).
- `recuperar.sh B` — desde el VPS.
- `recuperar.sh C` — clonando GitHub.

### Bugs corregidos en el camino
1. **`exportar_sesion.py` corrompía el chat.** El patrón `re.compile(r"[CLAVE]")`
   es una *clase de caracteres* (C, L, A, V, E), no el texto literal: por eso
   `WDC` salía como `WD[CLAVE SERVIDOR]` y `el kit` como `[CLAVE SERVIDOR]l kit`.
   7977 sustituciones en el kit. Corregido con `re.escape()`.
   La auditoría de secretos decía "0 fugas" y aun así el texto estaba roto:
   **una auditoría de fugas no detecta corrupción**, hace falta mirar el texto.
2. **El kit no llevaba los scripts del servidor.** La ruta era
   `$W/../usr/local/bin/*.sh`, que no existe. Ahora usa `sudo cp`.
3. **`RESTAURAR.sh` imprimía literalmente `$IP`** por un `<<'PASO'` entrecomillado.
4. **La clave antigua se colaba** en el kit al volver el detector dinámico.
   Ahora el exportador lee la clave actual **y** `/etc/marketattack/claves_rotadas.txt`.
5. **`SERVICIOS` se había borrado** al reescribir la lista blanca; lo cazaron
   las pruebas (2 fallos) antes de desplegar.
6. **El verificador de tiendas no comprobaba el nombre comercial**, solo el slug.

### Cómo verificarlo todo
```bash
sudo bash /usr/local/bin/verificar_respaldos.sh   # integridad de las 2 vías
sudo bash /tmp/verificar_kit.sh                   # kit: fugas + corrupción
```

### Pendiente del usuario (2 cosas, 2 minutos)
1. **Rotar el token del bot** en `@BotFather`: `/revoke` → elegir el bot.
2. **Activar el espejo automático del VPS en GitHub** (para no depender de la PC):
   ```bash
   sudo ssh-keygen -t ed25519 -C "vps-marketattack" -f /root/.ssh/id_ed25519
   sudo cat /root/.ssh/id_ed25519.pub
   ```
   Copiar esa llave en GitHub → repo → Settings → Deploy keys →
   Add deploy key → ☑ **Allow write access**.
   A partir de ahí `publicar_github.sh` sube solo, cada día a las 04:00.

### Más correcciones (2026-10-06, tarde)
- **El puente reprocesaba el historial al reiniciar.** `off = 0` estaba fijo en
  el código: cada reinicio leía todos los mensajes antiguos y volvía a
  responderlos. Ahora el offset se lee y se guarda en
  `/home/ubuntu/.marketattack_offset`.
- `guardar_offset.py` ancla el offset a mano (`python3 /usr/local/bin/guardar_offset.py`).
- La verificación final compara **huellas SSH reales**, no comentarios de las
  llaves: la primera versión daba un falso "llave antigua presente".
- `verificacion_final.sh` corre todos los días a las 07:00 y comprueba servicios,
  web, 404 real, las tres claves de opencode, las dos huellas SSH, que la llave
  del celular esté restringida, las 4 vías de respaldo y fugas de secretos.
- `verificacion_final.sh` **no lleva ninguna clave escrita**: lee la clave
  antigua de `/etc/marketattack/claves_rotadas.txt`. Por eso se colaba en el kit.
- `verificar_kit.sh` compara el número de scripts contra lo que hay realmente
  en `/usr/local/bin` (no un número fijo: si el kit trae 20 de 20, vale).
- `prueba_restauracion.sh` **restaura de verdad** (no dice "debería"): descomprime
  el kit, abre la DB, y corre `sha256sum -c` sobre el respaldo. Requiere que
 porque el chat se busque a 2 niveles (`chat/conversacion.md`).

### Recuperar de verdad (probado, no supuesto)
```bash
# Desde el celu, con el ZIP de Telegram descargado:
bash recuperar.sh A                    # busca en Descargas
bash recuperar.sh A /ruta/al/kit.zip   # o le dices cuál es

# Desde la PC con el VPS vivo:
bash recuperar.sh B

# Desde cualquier parte con GitHub:
bash recuperar.sh C
```

## Los 2 pasos que dependen de tu cuenta (ya automatizados)

Ambos están en un comando. Nada más hay que hacer a mano.

### 1) Renovar el token del bot
1. Telegram → **@BotFather** → `/revoke` → elige `marketattack_alertas_bot`
2. Te da un token nuevo (copia todo: `123456789:AAH...`)
3. En el VPS:
```bash
ssh -i ~/.ssh/ssh-key-marketattack-20260926.key ubuntu@157.137.203.223
sudo bash /usr/local/bin/activar_token.sh
```
El script valida el token contra Telegram, guarda copia de la config anterior,
lo instala, reinicia el puente, borra el offset viejo y regenera el kit.
Si el token está mal pegado, **no cambia nada**.

### 2) Activar el espejo automático en GitHub
```bash
sudo bash /usr/local/bin/activar_espejo.sh
```
Genera una llave **solo del VPS**, te la muestra para copiar, y cuando la
pegues en GitHub (Settings → Deploy keys → ☑ Allow write access) publica
el primer espejo. A partir de ahí sube solo cada día a las 04:00.

### Comprobación
El informe de las 08:00 ahora reporta las 4 vías y el resultado de
`verificar_respaldos.sh`. Si algo se rompe, lo ves sin preguntar.
- El verificador comprueba el cron **por nombre de script**, no por cantidad.
  Antes contaba reglas y se le pasó por alto que faltaba la del respaldo web.
  Probado: quitando una regla, avisa exactamente cuál falta.

---

## 2026-10-06 · Venta y captación desde Telegram

### Comandos nuevos de venta (Listos para usar)
| Comando | Qué hace |
|---|---|
| `/producto` | Catálogo completo de MARKETATTACK para mandar a un cliente |
| `/oferta` | Mensaje corto y listo para copiar y pegar en WhatsApp |
| `/precios` | Tabla de precios (Esencial 450k / Profesional 850k / Escala 1.4M COP) |
| `/prospecto Nombre \| Rubro \| Ciudad \| contacto \| nota` | Guarda un prospecto |
| `/prospectos` | Ver la lista de prospectos |

Los prospectos se guardan en `/var/lib/marketattack/prospectos/*.txt`,
uno por archivo, con fecha y hora de cada alta.

### El agente del Telegram tiene permisos reales
Verificado que puede **leer, escribir y usar internet** desde el proyecto
`/home/personalamd/Documentos/Default Project`. Se le copió el proyecto
completo de la PC (43 archivos) para que trabaje aunque la PC esté apagada.

Prueba: le pedí crear un archivo y lo creó de verdad.

### Pruebas
- Suite del puente ampliada a **27 pruebas** (16 válidas + 11 bloqueadas): todas OK.
- `pruebas_puente.py` quedó instalado en `/usr/local/bin/` para poder repetirlas.

---

## 9) DÓNDE ESTÁN LOS SECRETOS (no están aquí, a propósito)

| Qué | Dónde vive en el servidor |
|---|---|
| Contraseña vigente de opencode | `/root/CLAVE_OPENCODE.txt` |
| Contraseñas ya rotadas | `/etc/marketattack/claves_rotadas.txt` |
| Token del bot de Telegram | `/etc/marketattack/telegram.conf` |

```bash
# leer la contraseña vigente
sudo cat /root/CLAVE_OPENCODE.txt
```

Nunca se copian a este archivo, ni al repo, ni a Telegram. Es lo correcto.

---

## 10) 2026-10-11 — Mejoras locales (calidad y prestigio)

Trabajo hecho en el PC local (sin VPS), todo gratis, sin membresías.
Regla respetada: el motor `02_DEMO` se personaliza por cliente; cada avance
se respalda y se verifica. Nada ajeno a MARKETATTACK entra al respaldo.

### Herramientas nuevas
| Script | Para qué |
|---|---|
| `revisar_tienda.sh` | revisa una o TODAS las tiendas antes de publicar (restos de la demo, WhatsApp, precios, bug del carrito, QR, portada, og). Devuelve 0/1. |
| `probar_motor.sh` + `pruebas/motor.test.js` | pruebas automáticas del motor y de cada cliente (node, sin navegador). |
| `portada_tienda.py` | genera `portada.png` (1200×630, para la vista previa al compartir) y `favicon.png`. |
| `build_standalone.py` | reconstruye `tienda_autocontenida.html` a partir de las partes. |

### Vista previa al compartir (Open Graph)
`tienda.html` trae un bloque `<!--MA_HEAD:BEGIN-->…END-->`; el generador lo
rellena con `og:title`, `og:description`, `og:image`, `og:url`, Twitter Card
y JSON-LD (LocalBusiness). Al compartir el link en WhatsApp sale una tarjeta
con nombre, frase e imagen. El título de la pestaña lo fija `demo.js`.

### Carpeta del cliente limpia
Al generar un cliente: `index.html` = la tienda (así `/clientes/<slug>/` abre
la tienda) y se eliminan `kit.html`/`recuperar.html` (no aplican al cliente).

### Bugs corregidos (además de la ronda anterior)
- "¿cuánto vale?" no se reconocía como consulta de menú/precio → agregado.
- El motor usa la clave `whatsapp:` sin comillas; el revisor ahora acepta ambos formatos.
- Precios siempre con separador de miles ($5.000).

### Respaldo
- `backup_local.sh` **excluye `ProfitBlockchain-start/`** (proyecto ajeno) para
  no mezclarlo con MARKETATTACK.
- Comando único: `bash scripts/backup_local.sh` (verificado, SHA256 + auditoría).

### 2026-10-11 (segunda tanda) — Diferenciadores "top"
Nada de esto lo suelen ofrecer los competidores, todo gratis y probado.

- **Estado "Abierto/Cerrado" en vivo**: `estadoHorario()` en `demo.js` interpreta
  el horario del negocio ("Lunes a domingo de 6:00 a. m. a 8:00 p. m.", dos rangos,
  días sueltos) y muestra 🟢/🔴 con "cierra…/abre…". Si no entiende el texto, no
  miente: no muestra nada. Se actualiza cada minuto.
- **Botón Compartir**: usa el compartir nativo del celular o WhatsApp.
- **Mapa**: se incrusta la ubicación del negocio (Google Maps, sin API key).
- **App instalable (manifest.webmanifest)**: "Agregar a inicio" y se ve como app.
  (Offline real requiere HTTPS; el VPS hoy es http, por eso NO se puso service worker
  para no arriesgar caché vieja.)
- **Menú imprimible** (`menu_tienda.py`): genera `assets/menu.png` y `assets/menu.pdf`
  con la marca, listo para imprimir o enviar por WhatsApp. Enlace "📄 Menú imprimible"
  en la tienda.
- **QR con la marca** (`qr_tienda.py`): ahora en color, con marco y la inicial del
  negocio al centro (corrección de error alta). Sigue generándose por cliente.
- **Portada 1200×630 + íconos 128 y 512** (`portada_tienda.py`).
- `nuevo_cliente.py` limpia los artefactos de la demo antes de regenerar (nunca
  queda una imagen del ejemplo si algo falla).

### Verificación
- `probar_motor.sh`: motor 44/44 y cliente 44/44 (0 fallidas).
- `revisar_tienda.sh`: motor y cliente APROBADOS.
- HTTP 200 en menú.png/menu.pdf/icono.png/manifest/portada.

### 2026-10-14 — Recuperar acceso al VPS (SSH)
Estado: el VPS está EN LÍNEA (web HTTP 200, puerto 22 abierto) pero **no hay
llave válida en esta PC**.

Búsqueda hecha (solo material de MARKETATTACK; las llaves de otros proyectos
`profitblockchain-ssh.key` y `zarosalescol-oracle.key` NO se tocan):
- Recorrido completo del disco por llaves/certificados: NO está la de MARKETATTACK.
- Memoria de opencode (`opencode.db`): las 2 llaves RSA guardadas son de otros
  proyectos (huellas `kKmIGap5…` = ssh-key-2026-10-13.key y `RLSuza…`); ninguna
  es la de MARKETATTACK.
- Dropbox y `~/MarketAttack`: vacíos.
- No hay `~/.oci`, ni CLI `oci`, ni claves API de Oracle en el equipo.
- La llave buena es `ssh-key-marketattack-20260926.key`
  (huella `SHA256:VbRrdAfJiujLH/aNxcyjKtOBxrcvcJXbMSlqqLpspvo`) y quedó en el PC
  viejo (`/home/personalamd/Descargas/`).

Vías de recuperación:
1. **Oracle Cloud Shell** (recomendada, lista): el dueño tiene su login de Oracle
   guardado en Firefox (`idcs-1fc12c…identity.oraclecloud.com`). En Cloud Shell
   se pega `scripts/recuperar_acceso_vps.sh`, que agrega la llave nueva
   (`~/.ssh/id_ed25519`, pública `ssh-ed25519 AAAA…z7ENu`) a `ubuntu` usando
   "Run Command". Requiere el plugin "Compute Instance Run Command" activo.
2. Recuperar `ssh-key-marketattack-20260926.key` del PC viejo.
3. Último recurso: recrear la instancia.

## ── [X] RECUPERACIÓN DE ACCESO AL VPS (2026-10-15) — HECHO ─────────
- **IP NUEVA:** `157.137.203.223` (la vieja `149.130.190.118` quedó obsoleta).
- **SSH OK:** `ssh marketattack` (alias en `~/.ssh/config`) o
  `ssh -i ~/.ssh/id_ed25519 ubuntu@157.137.203.223`.
  Llaves autorizadas (2): `~/.ssh/id_ed25519` (PC) y la del celular
  (`telefono`, restringida al túnel `localhost:4096`).
- **HTTPS GRATIS OK:** https://157-137-203-223.sslip.io/ (nginx + Certbot /
  Let's Encrypt). Vence 2027-01-13 y se **auto-renueva** (systemd timer).
  HTTP (80) redirige a HTTPS.
- **Sitio servido:** `/var/www/marketattack` (site nginx `marketattack`).
- **Cómo se recuperó:** el agente Oracle ("Run Command") estaba roto y la consola
  serial rechazaba la llave; se recreó la instancia **conservando el volumen de
  arranque** e inyectando las llaves vía metadata `ssh_authorized_keys`;
  cloud-init las re-aplicó al arrancar → SSH funcionó.
- Referencias a la IP vieja actualizadas en el proyecto y en el VPS.

## ── [X] DESPLIEGUE DE LA VERSIÓN NUEVA + LIMPIEZA (2026-10-15) — HECHO ──
- **Publicado:** `02_DEMO/` → `/var/www/marketattack` vía `rsync` por SSH
  (sin `--delete`, preservando `descargas/` y `clientes/`). Sitio probado por el
  celular en https://157-137-203-223.sslip.io/
- **Cliente publicado:** `05_CLIENTES/arepas-dona-rosa/` →
  `/var/www/marketattack/clientes/arepas-dona-rosa/`.
- **`descargas/` restaurado:** el kit de recuperación se regeneró con
  `sudo bash /usr/local/bin/publicar_kit.sh` (usa `/var/backups/marketattack/kits`).
- **Llaves SSH saneadas:** quedaron SOLO 2 (`id_ed25519` PC + `telefono` celular).
  Respaldo en `/home/ubuntu/.ssh/authorized_keys.bak_*`.
- **Scripts corregidos:** `publicar.sh` (ahora publica PC→VPS por SSH, sin `--delete`),
  `verificacion_final.sh` (comprueba la web por HTTPS), `publicar_kit.sh` y
  `generar_restauracion.sh` (llave/alias nuevos).
- **Verificación del proyecto:** `verificacion_final.sh` → **TODO CORRECTO**.

### ⚠ Causa raíz de la "desaparición" del sitio (arreglado)
El cambio de `server_name` a `157-137-203-223.sslip.io` dejó las comprobaciones
internas (`http://127.0.0.1/...`) en **404**. El **watchdog** (cada 5 min) creía que
el sitio estaba caído y ejecutaba `publicar.sh` del VPS, que con `rsync --delete`
restauró un snapshot viejo desde el espejo `/home/personalamd/.../02_DEMO` y **borró
`descargas/` y `clientes/`**.
- **nginx:** el bloque `:80` ahora sirve el sitio a cualquier Host (p. ej.
  `127.0.0.1`) y solo redirige a HTTPS el dominio.
- **`/usr/local/bin/publicar.sh` del VPS:** sin `--delete` y excluyendo
  `descargas` y `clientes`.
- **Espejo del VPS** `/home/personalamd/Documentos/Default Project/02_DEMO`
  actualizado a la versión nueva (es de donde re-publica el watchdog).
- Comprobado: el watchdog ya no revierte y el sitio se mantiene con la versión nueva.

## ── [X] POLÍTICA DE RESPALDOS: SOLO MEJORAS VALIDADAS (2026-10-29) ──
- **Regla:** NO se respalda a ciegas. Primero se valida; solo si hay **cambios
  validados** se crea un respaldo. Nunca se guarda una versión con fallos.
- **VPS · 00:00 · `respaldo_diario_marketattack.sh` (auto):**
  1) valida con `verificacion_final.sh`; 2) si no hay cambios → no crea copia;
  3) si hay cambios → **nube** (kit + Telegram) + **local** (vías A y B) y
  GitHub si la llave está autorizada. Estado en
  `/var/backups/marketattack/.ultimo_validado.sha256`.
  Forzar tras una mejora aprobada: `sudo respaldo_diario_marketattack.sh --force`.
- **PC · 00:00 · `backup_local_si_validado.sh`:** solo respalda si hay cambios
  locales **y** el sitio en vivo valida. Estado en
  `~/MarketAttack_Respaldos/.ultimo_local.sha256`.
- **`verificacion_final.sh`** ahora devuelve **exit 1** si hay fallos (antes
  decía "TODO CORRECTO" pero no fallaba el comando).
- **GitHub (vía D) pendiente:** falta autorizar la llave pública del VPS
  (`/root/.ssh/id_ed25519.pub`) como *deploy key* con permiso de escritura en
  `marketattackpro/marketattack`. Requiere al dueño del repo.
- **Prueba real:** 1.ª pasada detectó el cambio y respaldó (A/B = 17 copias,
  Telegram OK); 2.ª pasada → "sin cambios validados", no duplicó.

## ── [X] CHAT CON IA REAL (2026-11-01) ──
- **Proveedor:** Groq (plan gratuito, sin tarjeta), cuenta del proyecto
  `marketattackpro@gmail.com`. Modelo `openai/gpt-oss-120b`.
  - Gemini NO se pudo usar: su proyecto exige **tarjeta** ("nivel gratuito no
    disponible para este proyecto"). No se agregó medio de pago.
- **Clave:** solo en el VPS, `/etc/marketattack/ia.conf` (root:www-data 640).
  Nunca se envía al navegador ni se sube al repositorio.
- **Backend:** `/usr/local/bin/marketattack_chat.py` (Python estándar, sin
  dependencias), servicio `marketattack-chat.service` (systemd, `Restart=always`,
  escucha solo en `127.0.0.1:8787`).
- **Ruta pública:** `https://157-137-203-223.sslip.io/api/chat` vía nginx
  (`location ^~ /api/chat`, timeouts 30 s, cuerpo máx. 64 KB).
- **Protecciones:** 20 mensajes/min por IP, 400/día por IP, tope global 3.000/día,
  mensaje máx. 500 caracteres, timeout 25 s.
- **Frontend:** `02_DEMO/tienda.html` y `05_CLIENTES/<slug>/tienda.html` llaman a
  `/api/chat` con el contexto público del negocio (menú, horario, ubicación,
  promos, FAQ). Si el backend falla, cae al motor local simulado (la tienda
  nunca se queda sin responder). La promo conserva la captura de prospectos.
- **Validación:** `verificacion_final.sh` incluye sección **CHAT IA**
  (servicio + health + prueba real). Si el proveedor externo falla, avisa pero
  NO bloquea los respaldos.
- **Prueba real:** tienda de Doña Rosa respondió domicilio/Bosa/25 min y la demo
  respondió combo familiar $65.000 y opciones veggie, con enlace a WhatsApp.
- **Pendiente:** el generador de clientes aún produce URLs `file://` y
  `http://IP` en metadatos/QR; corregir a HTTPS/dominio en una próxima mejora.

## ── [X] WHATSAPP DE LA DEMO (2026-11-01) ──
- Número de la tienda demo: **+57 323 331 6186** (antes 320 922 6563, un número familiar).
- Cambiado en `02_DEMO/assets/demo.js` y `02_DEMO/assets/tienda_autocontenida.html`.
- El botón flotante, el carrito y el chat toman el número de `CLIENTE.whatsapp`.
- `scripts/revisar_tienda.sh` actualizado: ahora detecta el número de la demo en tiendas de clientes.
- `tienda.html` carga `demo.js?v=20261101` para saltar la caché de 7 días.

## ── [X] LINKS Y QR CON HTTPS EN EL GENERADOR (2026-11-02) ──
- **Problema:** los clientes nuevos se creaban con links/QR `http://IP` y, si se
  generaban en el PC, con `file://`.
- **Ahora:** `nuevo_cliente.py` publica SIEMPRE
  `https://157-137-203-223.sslip.io/clientes/<slug>/` (link, vista previa y QR).
- **Dominio cambiable sin tocar código:** variable `MA_URL_BASE` o `--url-base`
  (ej. `MA_URL_BASE="https://midominio.com"`). Valida que empiece por http/https.
- **Verificación interna:** comprueba en `127.0.0.1` (no depende de la URL
  pública ni de internet) y sigue exigiendo `VERIFICADO=200`.
- **Metadatos:** Open Graph / Twitter / JSON-LD con la URL HTTPS del dominio.
- **`qr_tienda.py`:** ya no lleva la IP vieja como valor por defecto.
- **`revisar_tienda.sh`:** nueva regla que falla si una tienda contiene
  `file://` o `http://IP` en los HTML (evita que el fallo vuelva).
- **El generador del VPS estaba desactualizado** (apuntaba a 149.130.190.118 y
  no creaba portada, menú, manifest ni metadatos): se instaló la versión del
  proyecto en `/usr/local/bin/nuevo_cliente.py`. También se sincronizó el motor
  `02_DEMO` y los scripts auxiliares al proyecto del servidor.
- **Tienda de Doña Rosa:** sus metadatos `file://` se corrigieron a HTTPS
  (mismo contenido, solo los links de vista previa).
- **Prueba real:** se generó una tienda temporal en el VPS: link, QR, JS e
  índice respondieron 200; el QR coincidió exactamente con la URL HTTPS y el
  chat respondió con el WhatsApp de ese cliente. Luego se eliminó.

## ── [X] RESPALDO EN GITHUB ACTIVO (2026-11-02) ──
- **Cuenta real:** `marketattackpro` (la cuenta `marketattack` no existe).
- **Repositorio:** `marketattackpro/marketattack`, público, rama `main`.
- **Llave del VPS** (`/root/.ssh/id_ed25519.pub`, comentario `vps-marketattack`)
  autorizada como **deploy key con "Allow write access"**.
- **`publicar_github.sh` corregido** (tenía 4 fallos):
  1. Apuntaba a `gtcorebynet-jpg/marketattack` (repo equivocado); ahora al correcto.
  2. Decía "llave no aceptada" siempre: `ssh -T git@github.com` responde
     "autenticado" pero sale con error porque GitHub no da shell. Ahora se
     comprueba el mensaje, no el código de salida.
  3. Copiaba el respaldo ANTES de clonar y luego `rm -rf` borraba la copia;
     ahora clona/actualiza primero y después copia.
  4. Sobrescribía el `.gitignore` del repositorio; ahora solo añade lo que falte.
- **Qué publica:** `08_SERVIDOR/scripts`, `08_SERVIDOR/config` (saneada),
  `08_SERVIDOR/web` (web publicada), `ESTADO.txt` y `SHA256SUMS`.
- **Seguridad:** si detecta algo con pinta de secreto (`gsk_`, llaves privadas,
  tokens, contraseñas) **no sube nada** y avisa.
- **Validación:** `verificacion_final.sh` → vía D "llave del VPS autorizada".
- **Prueba real:** commit `respaldo automático del VPS 2026-11-02 14:52` en
  `main`; el respaldo completo posterior volvió a empujar y dio TODO CORRECTO.

## ── [X] DOMINIO GRATUITO DUCKDNS (2026-11-02) ──
- **Dominio:** `https://marketattack.duckdns.org` → `157.137.203.223`.
  Cuenta `marketattackpro@gmail.com` (la misma del proyecto). Es un puente
  **gratis**; el dominio propio se compra cuando entre el primer cliente.
- **HTTPS:** el certificado de Let's Encrypt se amplió para cubrir los dos
  nombres (`157-137-203-223.sslip.io` + `marketattack.duckdns.org`); vence
  2027-01-31 y se renueva solo. El nombre viejo **sigue funcionando**.
- **Redirección:** `http://…duckdns.org` → `https://…duckdns.org` (301).
  Las comprobaciones internas por `127.0.0.1` **no** se redirigen.
- **Actualización automática:** `/usr/local/bin/duckdns_actualizar.sh` +
  `/etc/marketattack/duckdns.conf` (root, permisos 600). Cron: al arrancar
  (`@reboot`) y cada 30 minutos. Registro en `/var/log/marketattack-duckdns.log`.
  El script confirma la respuesta `OK` de DuckDNS y que el DNS coincide con la
  IP real del servidor.
- **Nuevo dominio por defecto** en `nuevo_cliente.py` (`URL_BASE`),
  `publicar.sh` (`BASE`), `verificacion_final.sh` (`BASE`) y `qr_tienda.py`.
  Se puede seguir cambiando sin tocar código con `MA_URL_BASE` / `--url-base`.
- **Tienda de Doña Rosa:** metadatos (Open Graph, Twitter, JSON-LD), vista
  previa y **QR** regenerados con el dominio nuevo. Su contenido no cambió.
- **`verificacion_final.sh`:** ahora exige también la regla de cron de DuckDNS
  (7 reglas en total).
- **Prueba real:** tienda temporal `prueba-dominio` generada en el VPS:
  link/QR/índice/autocontenida → 200; el QR salió **idéntico píxel a píxel** al
  generado desde la URL esperada; el chat respondió con el WhatsApp de ese
  cliente. Se eliminó la tienda de prueba y su copia publicada.
- **Validación:** `verificacion_final.sh` → **TODO CORRECTO**;
  `revisar_tienda.sh arepas-dona-rosa` → **APROBADA, 0 avisos**.

## ── [X] COBROS: MÉTODO SIMPLE (2026-11-03) ──
- **Método elegido para empezar:** **Nequi / Daviplata** con comprobante por
  WhatsApp. Sin pasarela ni comisión. La transferencia bancaria y el link de
  pago con tarjeta se agregan cuando el volumen lo pida.
- **Regla de oro:** no se publica una tienda real sin el primer mes pagado.
  La demo se muestra gratis; la activación es contra pago confirmado.
- **Precios vigentes (los que ya usaba el bot):** Esencial $450.000/mes,
  Profesional $850.000/mes, Escala $1.400.000/mes. Sin permanencia.
- **Herramientas nuevas en `07_COBROS/`:**
  - `recibo.html`: recibo/cuenta de cobro imprimible (Guardar PDF). Calcula
    total y saldo, elige plan, marca PENDIENTE/PAGADO y guarda los datos de
    pago una sola vez en el navegador (localStorage).
  - `COMO_COBRAR.md`: reglas, calendario de recordatorios y 5 mensajes listos
    para copiar (cobro, recordatorio, confirmación y pausa).
  - `registro_pagos.csv`: registro simple de cada pago.
- **Ciclo mensual:** recordatorio 5 días antes → cuenta de cobro el día 1 →
  aviso el día 5 → pausar (no borrar) el día 6 hasta que pague.
- **Corrección de paso:** `catalogo.sh` mostraba la URL vieja
  `marketattack.netlify.app`; ahora usa `marketattack.duckdns.org`. También se
  corrigió “Factura issued electrónicamente” → “Factura electrónica disponible”.
- **Validación:** recibo probado en navegador: cambio de plan, abono, saldo,
  estado y guardado de datos de pago funcionan sin errores; sin desbordes en
  pantalla ni al tamaño A4.
- **Datos confirmados:** Nequi/Daviplata **323 331 6186 — Gerardo Torres**.
  Viven en el recibo y en `/etc/marketattack/pagos.conf` (root, 600), fuera del
  código para no publicarlos en el espejo de GitHub. El comando `/precios` del
  bot ya muestra estos datos al prospecto.
- **Ensayo completo hecho:** recibo `MA-20261103-001` (Carlos Ramírez /
  Panadería La Espiga, Profesional $850.000, Nequi, abono total, PAGADO).
  Total $850.000 y saldo $0 correctos; la fila de 13 columnas valida para
  `registro_pagos.csv`. El ejemplo visual quedó en `recibo_ejemplo.html`
  (no se usa para cobrar). El recibo ya no pisa el número ni el mes si vienen
  prellenados.

## ── [X] VIGILANCIA Y AVISOS AL CELULAR (2026-11-03) ──
- **Vigilante interno** (`watchdog_marketattack.sh`, cada 5 min):
  - Ahora también revisa `marketattack-chat` (antes no).
  - Comprueba el sitio real por **HTTPS público** (como lo ve el cliente) y no
    solo por `127.0.0.1`.
  - Revisa que al certificado le queden más de 14 días.
  - Si algo no se puede reparar, manda **aviso a Telegram** con el detalle.
    Máximo 1 aviso cada 30 minutos mientras siga el problema, y un mensaje de
    “todo normal” cuando se resuelve.
  - Bot de avisos: `@marketattack_alertas_bot` (“MarketAttack Alertas”).
  - Probado: llegaron al celular el aviso de prueba y el de recuperación.
- **Vigilancia externa** (`.github/workflows/vigilancia_externa.yml`): GitHub
  revisa `https://marketattack.duckdns.org/` cada 10 minutos **desde fuera del
  VPS**. Si no responde, abre un aviso ("🚨 MARKETATTACK no responde") y GitHub
  manda correo; al volver, lo cierra solo. No depende de la PC ni de una cuenta
  nueva. También corre en cada push (así se puede probar a mano).
  - **Probada:** 2026-11-03 16:04 UTC, run `41670449616` → sitio revisado (200,
    con el nombre de la marca), sin avisos falsos. Pasos: "Revisar el sitio"
    OK, "Abrir aviso" omitido, "Cerrar aviso" OK.
- **Guía de operación:** `MONITOREO.md` (qué vigila cada uno, qué hacer cuando
  llega un aviso y cómo activar UptimeRobot para push al celular).
- **Corrección de paso:** `publicar_github.sh` ahora hace `fetch` + `rebase`
  antes de subir (y reintenta tras sincronizar). El respaldo de 16:06 falló el
  push porque el repositorio del VPS se había quedado atrás al agregar el
  workflow; el de 16:07 subió bien (`5ea254a`).
- **Cobertura:** el vigilante interno cubre fallas de servicios, páginas y
  certificado; el de GitHub cubre la caída total del servidor o de la red.
- **Opcional recomendado:** UptimeRobot (gratis) con aviso push al celular;
  requiere crear la cuenta con `marketattackpro@gmail.com` (2 minutos, pide
  confirmar el correo). Se activa cuando entre el primer cliente.



## ── [X] LISTO PARA EL PRIMER CLIENTE: ACEPTACIÓN REAL (2026-11-03/04) ──

### Ensayo de restauración (ahora sí completo)
- **`simulacro_restauracion.sh`** restaura el último respaldo en una carpeta
  temporal, verifica checksums, levanta el sitio, comprueba la base del chat,
  **crea un cliente nuevo con la plantilla restaurada**, lo publica y lo abre.
- **Resultado:** 156 archivos, **2 s**, todo OK.
- Encontró y se corrigieron 2 fallos reales del respaldo:
  1. No incluía `02_DEMO` ni `05_CLIENTES` → el respaldo levantaba el sitio,
     pero no servía para crear clientes.
  2. Faltaban `portada_tienda.py` y `menu_tienda.py` (viven en el proyecto, no
     en `/usr/local/bin`) → la tienda nueva salía sin portada, ícono ni menú.
- Programado el **día 1 de cada mes a las 9:00** (8ª regla de cron).

### Prueba de aceptación de punta a punta
- **`prueba_aceptacion.sh`** (nuevo, en `/usr/local/bin` y en `scripts/`):
  genera un cliente real, corre el verificador, comprueba contenido, QR, menú,
  PWA, chat con IA (local y por internet) y recibo; luego borra la prueba y
  confirma que el sitio y la tienda demo siguen bien.
- **Resultado final:** `ACEPTACIÓN COMPLETA — TODO FUNCIONA` en **2 s**.
- Se corre cuando se quiera: `sudo /usr/local/bin/prueba_aceptacion.sh`.

### Fallo grave encontrado: el QR no escaneaba
- El QR llevaba un círculo con la inicial al **22 % del ancho** y tapaba
  patrones del código: `zbarimg` no lo podía leer (0 símbolos).
- **Corregido** `qr_tienda.py`: logo al **12 %**, y **verifica con un lector
  real** antes de guardar; si no lee, genera sin logo; si aún falla, QR simple.
- Se instaló `zbar-tools` en el VPS y se regeneró el QR de Doña Rosa: ahora
  escanea y apunta al link correcto.
- `verificar_tienda.sh` ahora **lee el QR** (no solo revisa que sea PNG).

### Verificador de tiendas corregido
- Revisaba una **IP vieja** (`149.130.190.118`) → marcaba “internet 000”.
- Ahora comprueba por **HTTPS público** (`marketattack.duckdns.org`) y además:
  assets, portada, menú PNG/PDF, WhatsApp, datos del cliente y QR decodificado.

### La página del cliente ya no es una demo
- Las tiendas de clientes conservaban textos de demo (“empresa ficticia de
  prueba”, “Tienda Demo IA”) y pestañas internas (Panel/Resumen/Marketing).
  Esos paneles funcionan solo en el navegador de quien mira (localStorage), así
  que **no servían para un cliente real**.
- `nuevo_cliente.py` ahora **limpia la página**: quita textos de demo, deja
  solo Chat y Menú, y conserva la marca del negocio. `02_DEMO` **no se tocó**
  (sigue siendo la demo de ventas).
- El encabezado dice “Tienda online”, el subtítulo usa la tagline real y la
  versión autocontenida también queda limpia.
- Se regeneró la página de **Doña Rosa** con el mismo criterio.
- **Pendiente honesto:** el panel de prospectos y el resumen volverán cuando
  exista un backend real (hoy son por navegador). Por eso el plan Esencial ya
  no promete “panel” en las condiciones.

### Arepas Doña Rosa es la DEMO comercial (no un cliente)
- Es el **ejemplo** que se le muestra al prospecto: catálogo, carrito, chat y QR
  funcionando. No se trata como cliente real.
- Lleva una barra discreta arriba: **“🧪 Tienda de ejemplo · así se vería la
  tuya”** con un botón **“Quiero una así”** que abre el WhatsApp real
  (323 331 6186). Así la demo también sirve para captar interesados.
- Cuando entre un cliente de verdad se crea con **su** nombre, su WhatsApp y su
  catálogo; no se reutiliza la demo.

### Chat con IA
- La tienda envía **nombre, horario, ubicación, menú, promos y FAQs**.
- Probado con el catálogo real: responde con productos y precios correctos
  (`Producto Uno: $12.000`), tanto local como por nginx/HTTPS.

### Operación y legal
- `05_OPERACION/GUIA_ENTREGA.md` — de “sí” a tienda publicada, en 7 pasos.
- `05_OPERACION/FICHA_CLIENTE.md` — datos a pedir.
- `05_OPERACION/POLITICA_SOPORTE.md` — canales, tiempos, límites, pausa.
- `05_OPERACION/MENSAJES_CLIENTE.md` — 15 mensajes listos para WhatsApp.
- `05_OPERACION/registro_soporte.csv` — bitácora de reclamos.
- `05_OPERACION/SOLICITUD_INICIO_CLIENTE.md` — mensaje y checklist para pedir
  los datos del cliente una sola vez, sin olvidar nada.
- `10_LEGAL/condiciones_servicio.html` y `politica_privacidad.html` — listos
  para PDF. **Faltan 3 datos del prestador** (nombre, cédula/NIT, ciudad) que
  están marcados en amarillo; no se envían al cliente sin completarlos.
- El respaldo ahora incluye `10_LEGAL` y el ensayo comprueba que esté.

### Fallo grave del carrito (encontrado en navegador real)
- Al confirmar el pedido, el mensaje de WhatsApp llegaba **vacío y con Total $0**:
  el código vaciaba el carrito **antes** de que se armara el texto (un
  `setTimeout` de 500 ms leía el carrito ya borrado).
- **Corregido** en `02_DEMO/assets/carrito.js`: el pedido se arma con
  `urlPedido()` **antes** de vaciar el carrito. El mensaje ahora lleva nombre
  del negocio, productos, cantidades, subtotales, total y medio de pago.
- Probado en navegador real: 2 productos → `$14.000`, y también en la versión
  autocontenida.
- `prueba_aceptacion.sh` ahora **vigila el orden** (arma antes de vaciar) para
  que el fallo no vuelva.
- **Caché corregida:** nginx guardaba JS/CSS **7 días**, así que una
  actualización no se veía. Ahora JS/CSS se revalidan siempre (`no-cache`) y
  las imágenes duran 1 hora. Los cambios se ven al recargar.

### Caché y espejo público de GitHub
- nginx guardaba JS/CSS **7 días**, así que una actualización no se veía.
  Ahora JS/CSS se revalidan siempre (`no-cache`) y las imágenes duran 1 hora.
- El espejo de GitHub ahora publica también `02_DEMO`, `05_OPERACION` y
  `10_LEGAL` (antes el motor del repo estaba viejo).
- **Privacidad:** el repositorio es público, así que el espejo **excluye las
  carpetas de clientes** (`web/clientes` y todo `05_CLIENTES` que no sea
  plantilla/ejemplo). Los datos de clientes solo van en los respaldos privados.

### Reglas de oro que se mantienen
- No se publica tienda real sin el primer mes pagado.
- Un respaldo solo vale si restaura: el ensayo es mensual.
- Nada de prometer 24/7: un servidor, RPO 24 h, recuperación 30–60 min.

### Respaldo de esta mejora
- Servidor: `completo_20261104_0124.tar.gz` (7.0 MB, 3 clientes, 10_LEGAL,
  45 scripts) — vías A y B.
- GitHub: `4264c22` (la vigilancia externa corrió en verde tras el push).
- PC: `MARKETATTACK_local_20261103_2025.zip` (122 archivos, con legal y
  operación).
- PC → nube (Telegram): kit del día enviado.
- Validación general: `TODO CORRECTO` (8 reglas de cron, 0 fugas de secretos).

### Recepción de datos del cliente por Telegram
- El bot ya no solo manda avisos: también **recibe y guarda** los datos del
  cliente. Así se puede trabajar desde el celular cuando el PC está apagado.
- Comandos nuevos: `/solicitud`, `/solicitud corta`, `/datos`, `/captura`,
  `/fin`, `/cancelar`.
- Si el mensaje pegado trae 4 o más campos de la ficha, se guarda solo.
- Acepta fotos, PDF, Excel e imágenes; límite 20 MB por archivo.
- Todo queda en `05_CLIENTES/_entradas/` con `.txt` + `.json` y `adjuntos/`.
  Esa carpeta **no** se publica en GitHub; viaja en los respaldos privados.
- La solicitud se amplió de 11 a 42 puntos agrupados en 8 bloques:
  negocio, contacto, catálogo, pedidos/entrega, pagos, marca, operación y
  legal.
- Solo el chat autorizado puede escribir. Los nombres de archivo se generan
  con fecha; no se usa ninguna ruta enviada por el usuario.
- Documentos actualizados: `SOLICITUD_INICIO_CLIENTE.md`,
  `SOLICITUD_CORTA.md`, `FICHA_CLIENTE.md`, `RECEPCION_DATOS_TELEGRAM.md`.
- Probado con ficha temporal, `/datos`, captura de dos mensajes, adjunto real
  descargado desde Telegram y cancelación; los archivos de prueba se borraron.
- La prueba de aceptación ahora incluye el bloque **8) recepción de datos por
  Telegram** y corre aislada en una carpeta temporal.
- Respaldo de esta mejora: `completo_20261105_0058.tar.gz` (35 copias en las
  vías A y B). GitHub y PC se actualizan al cerrar el cambio.

### Respuesta del bot por Telegram (chat de ida y vuelta)
- El bot dejó de quedarse mudo: si el modelo no responde, contesta con un
  aviso claro en vez de bloquear el hilo.
- Se cambió el modelo de conversación a **Groq `openai/gpt-oss-120b`**, porque
  el modelo gratuito anterior agotó su cuota diaria
  (“Free usage exceeded, subscribe to Go”).
- La clave de Groq se registra con `configurar_modelo.sh`, que lee la que ya
  usa el chat de la tienda (`/etc/marketattack/ia.conf`) y la guarda en
  OpenCode. Ese paso hay que repetirlo después de restaurar un respaldo.
- Se creó una **sesión nueva** para Telegram (`Telegram MARKETATTACK`) porque
  la anterior tenía más de 1.000 mensajes y no cabía en el modelo nuevo.
- El bot ahora avisa **“📥 Recibido, pensando…”** y tiene un límite de espera
  de 150 s; una demora ya no deja el servicio trabado.
- Probado de punta a punta: un mensaje llega, el agente responde y el usuario
  recibe la respuesta en Telegram.
- La prueba de aceptación (bloque 8) también comprueba que, si el modelo falla,
  el bot avisa en vez de quedarse callado.

