# GUÍA DE ENTREGA — de “sí” a tienda publicada

Tiempo total: **30 a 60 minutos** por cliente.
Regla de oro: **no se publica sin el primer mes pagado**.

## Antes de empezar

- [ ] El cliente aceptó el plan y el precio.
- [ ] Le enviaste las condiciones del servicio y la política de privacidad
      (`10_LEGAL/`).
- [ ] Recibiste el pago del primer mes (Nequi/Daviplata) y el comprobante.

## 1. Pedir los datos (10 min)

Usa el mensaje de `FICHA_CLIENTE.md`. Necesitas:

- Nombre del negocio y nombre de la persona.
- WhatsApp (con indicativo 57).
- Qué vende, precios y descripción corta.
- Horario y zona/ciudad.
- Métodos de pago y si hace domicilio.
- Logo o fotos (opcional).
- Promoción o frase de bienvenida (opcional).

## 2. Cobrar (5 min)

1. Abre `07_COBROS/recibo.html`.
2. Llena cliente, negocio, plan y mes.
3. Guarda como PDF y envíalo por WhatsApp.
4. Al confirmar el pago: marca **PAGADO** y anota la fila en
   `07_COBROS/registro_pagos.csv`.

## 3. Generar la tienda (5 min)

En el VPS (o donde esté el proyecto):

```bash
cd "/home/personalamd/Documentos/Default Project"
sudo python3 scripts/nuevo_cliente.py \
  --nombre "Panadería La Espiga" \
  --whatsapp "573001234567" \
  --tagline "Pan fresco todos los días" \
  --horario "Lunes a sábado, 6:00 a.m. a 8:00 p.m." \
  --ubicacion "Soacha" \
  --menu "Pan tajado|5000|Pan de la casa" \
  --menu "Café|3000|Café caliente" \
  --promo "Pide antes de las 10 a.m. y te llega en el día" \
  --url-base "https://marketattack.duckdns.org"
```

Anota lo que imprime: `SLUG`, `LINK` y `VERIFICADO`.
Debe decir **`VERIFICADO=200`**.

> El `slug` es el nombre corto de la carpeta. Ejemplo: `panaderia-la-espiga`.

## 4. Revisar (5 min)

```bash
sudo /usr/local/bin/verificar_tienda.sh panaderia-la-espiga
```

Debe decir **APROBADA, 0 avisos**. Si hay avisos, se corrigen antes de
mostrarla.

Revisa tú mismo en el celular:

- Abre el link y prueba agregar un producto al carrito.
- Toca “Pedir por WhatsApp” y confirma que abre el chat correcto.
- Abre el QR y escanéalo con la cámara.

## 5. Entregar (10 min)

Envíale por WhatsApp:

1. El **link**: `https://marketattack.duckdns.org/clientes/<slug>/tienda.html`
2. El **QR** (`qr.png`) para que lo ponga en el local.
3. El mensaje de entrega de `MENSAJES_CLIENTE.md`.

## 6. Capacitar (15 min)

Por llamada o audio, muéstrale:

- Cómo se ve un pedido que llega a su WhatsApp.
- Que **él** confirma el pedido y el pago (la tienda no cobra sola).
- Cómo pedir cambios: te escribe y tú los haces.
- Que no comparta el link con otros negocios (es su tienda).

## 7. Cerrar

- [ ] Anotar el pago en `registro_pagos.csv`.
- [ ] Guardar la ficha en `05_CLIENTES/<slug>/`.
- [ ] Hacer respaldo (`/usr/local/bin/respaldo_diario_marketattack.sh --force`).
- [ ] Agendar seguimiento a los 7 días.
- [ ] Agendar el cobro del mes siguiente (5 días antes del vencimiento).

## Si algo falla después

1. Mira el aviso de Telegram.
2. Revisa el sitio y el log:
   `sudo tail -50 /var/log/marketattack_watchdog.log`
3. Si la tienda de un cliente se rompió, vuelve a generarla con los datos de
   `05_CLIENTES/<slug>/` (no se pierde nada).
