# RECEPCIÓN DE DATOS POR TELEGRAM

Cómo funciona el bot `@marketattack_alertas_bot` para recibir y guardar los
datos de un cliente sin depender de la PC ni del chat de OpenCode.

---

## 1. Qué comandos hay

| Comando | Qué hace |
|---|---|
| `/solicitud` | Envía la ficha completa lista para copiar y mandar al cliente. |
| `/solicitud corta` | Envía la versión breve. |
| `/datos` | Explica cómo guardar y muestra si hay una captura abierta. |
| `/datos <texto>` | Guarda ese texto como una entrada de cliente. |
| `/captura` | Abre un borrador para recibir los datos en varios mensajes. |
| `/fin` | Cierra el borrador y lo archiva como entrada. |
| `/cancelar` | Descarta el borrador sin guardar. |
| `/estado` | Muestra, entre otras cosas, cuántas entradas hay. |

Si el mensaje pegado trae **4 o más campos** de la ficha (por ejemplo
`Nombre del negocio:`, `WhatsApp:`, `Productos:` y `Ciudad:`), el bot lo
guarda automáticamente aunque no se use un comando.

---

## 2. Dónde queda guardado

Todo va a la carpeta privada del proyecto:

```
05_CLIENTES/_entradas/
├── cliente_AAAAMMDD_HHMMSS.txt    ← texto original, tal como llegó
├── cliente_AAAAMMDD_HHMMSS.json   ← fecha, origen y campos detectados
└── adjuntos/
    ├── AAAAMMDD_HHMMSS_logo.png
    ├── AAAAMMDD_HHMMSS_foto.jpg
    └── AAAAMMDD_HHMMSS_lista.pdf
```

Los archivos se crean con permisos `0640` y pertenecen al dueño del proyecto.
La carpeta `05_CLIENTES` **no se publica** en el espejo público de GitHub:
solo viaja en los respaldos privados (servidor, espejo de rescate, Telegram
y PC).

---

## 3. Qué acepta

- Texto normal.
- Fotos (logo, productos, local).
- Documentos PDF, Excel, Word e imágenes enviadas como archivo.
- Leyenda o descripción que acompañe una foto o documento.

Límite por archivo: **20 MB**. Si pesa más, Telegram no lo entrega al bot y
se avisa por el chat.

---

## 4. Seguridad

- El bot solo procesa mensajes del `TELEGRAM_CHAT_ID` autorizado.
- Los nombres de archivo se generan con fecha y se limpian; nunca se usa una
  ruta enviada por el usuario.
- El texto se limita a 30.000 caracteres y se eliminan caracteres de control.
- No se ejecuta nada de lo que llega: solo se escribe en la carpeta de
  entradas.
- Los datos no se publican en la web ni en el repositorio público.

---

## 5. Flujo recomendado

1. `/solicitud` y reenviar el mensaje al cliente.
2. Cuando responda, reenviar su respuesta al bot:
   - mensaje único → `/datos <texto>`.
   - varios mensajes → `/captura`, reenviar cada parte, `/fin`.
3. Enviar logo y fotos directamente al bot.
4. Revisar la confirmación y ver qué campos faltan.
5. Completar la ficha interna y crear la tienda con `/cliente`.

---

## 6. Prueba de que funciona

La recepción se probó con una ficha temporal:

- Se guardó el `.txt` y el `.json`.
- Se detectaron negocio, WhatsApp, ciudad, horario, productos y pagos.
- Se archivó una captura de dos mensajes en un solo archivo.
- Se canceló una captura sin dejar basura.
- Los archivos de prueba se borraron después.
