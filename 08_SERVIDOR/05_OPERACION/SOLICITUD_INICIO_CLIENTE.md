# SOLICITUD DE INICIO — qué pedirle al cliente

Documento para usar cuando el cliente dice **“sí, quiero la tienda”**.
El objetivo es pedir **una sola vez**, en un solo mensaje, todo lo necesario
para publicar sin devolverse.

---

## 1. Mensaje completo (copiar y pegar)

```
¡Hola [NOMBRE]! 🙌 Bienvenido(a) a MARKETATTACK.

Para dejarte la tienda completa y vendiendo desde el primer día, cuéntame
esto. Puedes responder en un solo mensaje o por partes. Si algo no lo tienes,
escribe “no tengo”.

1) NEGOCIO
• Nombre exacto como debe aparecer:
• Nombre de quien atiende / dueño:
• ¿Qué vendes? (una frase):
• ¿Qué te hace diferente?:
• Historia o años del negocio (opcional):

2) CONTACTO
• WhatsApp para pedidos (con 57, sin + ni espacios):
• Teléfono alterno:
• Ciudad, barrio y dirección o punto de referencia:
• ¿Local físico visitable?:
• Instagram / Facebook / TikTok:
• Página web o catálogo actual:

3) CATÁLOGO (lo más importante)
• Lista de productos así: nombre | precio | descripción corta | categoría |
  disponible (sí/no)
  Ej: Arepa de queso | 8000 | Queso doble | Arepas | sí
• ¿Cuántos productos manejas en total?:
• ¿Hay agotados, por encargo o de temporada?:
• ¿Combos, promociones o precios por mayor?:
• ¿Cada cuánto cambian los precios?:

4) PEDIDOS Y ENTREGA
• Horario de atención (días y horas):
• ¿Cómo prefieres recibir pedidos? WhatsApp / llamada / ambos:
• ¿Domicilio? Zonas y costo:
• Tiempo promedio de preparación o entrega:
• ¿Pedido mínimo?:
• ¿Qué hacemos si un producto no está disponible?:
• ¿Pedidos para fechas especiales o por encargo?:

5) PAGOS
• Métodos: Nequi / Daviplata / transferencia / efectivo / tarjeta:
• Número o titular para pagos (solo si quieres mostrarlo):
• ¿Pago contra entrega?:
• ¿Pides anticipo? ¿En qué casos?:
• ¿Quién confirma el pago y cómo?:

6) MARCA E IMAGEN
• Logo (archivo o foto; si no tienes, lo hacemos):
• De 3 a 10 fotos de productos o del local:
• Colores o estilo que te gustan:
• Frase de bienvenida o promoción:
• ¿Algo que NO quieres que aparezca?:

7) OPERACIÓN Y SOPORTE
• ¿Quién responde los pedidos y en qué horario?:
• ¿Qué hacemos fuera de horario?:
• ¿Garantía, cambios o devoluciones?:
• ¿Qué datos necesitas del comprador? (nombre, dirección, referencia…):
• ¿Alguna regla especial? (zona, edad, mínimo…):

8) LEGAL Y AUTORIZACIÓN
• ¿Persona natural o empresa con RUT/NIT?:
• ¿Autorizas usar tu logo y fotos en la tienda y redes de MARKETATTACK?:
• ¿Autorizas que los pedidos lleguen a tu WhatsApp?:
• Nombre y documento de quien autoriza (opcional):

📎 Si tienes logo, fotos o lista de precios en PDF/Excel, envíalos por aquí.
✅ Con esto armo tu tienda, te mando el link para revisar y publicamos.
```

> También está disponible la **versión corta** para clientes que responden
> poco: `05_OPERACION/SOLICITUD_CORTA.md` o el comando `/solicitud corta`
> en Telegram.

---

## 2. Por qué se pide cada bloque

| Bloque | Para qué sirve |
|---|---|
| Negocio | Nombre, propuesta y diferencial de la tienda. |
| Contacto | WhatsApp real de pedidos, zona y redes. |
| Catálogo | Precios, categorías, disponibilidad y fotos. Sin esto no hay tienda. |
| Pedidos y entrega | Horario, domicilio, tiempos y reglas para no prometer de más. |
| Pagos | Métodos y confirmación del pago. |
| Marca | Logo, fotos, colores y textos. |
| Operación | Quién responde, garantías y datos que necesita del comprador. |
| Legal | Autorización de uso de marca, fotos y pedidos. |

---

## 3. Cómo recibir los datos por Telegram

El bot `@marketattack_alertas_bot` ya guarda los datos de forma privada.
Solo acepta el chat autorizado.

1. Enviar la solicitud con `/solicitud` (o `/solicitud corta`).
2. Cuando el cliente responda:
   - **Un solo mensaje:** `/datos` + el texto.
   - **Por partes:** `/captura` → enviar los mensajes → `/fin`.
   - **Ficha completa pegada:** se guarda automáticamente si detecta varios
     campos.
3. Los archivos quedan en `05_CLIENTES/_entradas/`:
   - `cliente_AAAAMMDD_HHMMSS.txt` — texto original.
   - `cliente_AAAAMMDD_HHMMSS.json` — campos detectados.
   - `adjuntos/` — logo, fotos, PDF o Excel.
4. Confirmar al cliente que se recibió y decirle qué falta, si algo falta.

Detalle técnico y de seguridad: `05_OPERACION/RECEPCION_DATOS_TELEGRAM.md`.

---

## 4. Lo mínimo para poder empezar (si el cliente responde corto)

1. **Nombre del negocio** y **nombre del dueño**.
2. **WhatsApp** que recibe pedidos (con 57).
3. **De 5 a 10 productos con precio**.
4. **Horario** y **ciudad/barrio**.
5. **Forma de pago** que acepta.

Lo demás (fotos, promo, domicilio, garantías) se puede completar después sin
frenar la publicación.

---

## 5. Cómo se pide (para que no quede incompleto)

1. Enviar el mensaje de la sección 1 por WhatsApp o Telegram.
2. Si responde por partes, usar `/captura` y `/fin` para no perder nada.
3. Marcar lo que falta **sin volver a preguntar todo**.
4. Confirmar por escrito **precios, horario y WhatsApp** antes de publicar.
5. Enviar la **cuenta de cobro** del primer mes.
6. Publicar **solo cuando el pago esté confirmado**.
7. Enviar el link y el QR, y explicar en 3 pasos cómo recibe pedidos.

---

## 6. Reglas para escribir los datos en el sistema

- WhatsApp **con 57 y sin espacios**: `573001234567`.
- Precios **sin puntos ni signos**: `12000`, no `$12.000`.
- Cada producto: `Nombre|Precio|Descripción corta`.
- Si no hay logo, se usa el ícono de MARKETATTACK.
- Si no hay descripción, se escribe una corta y útil.
- Nunca se promete una fecha que no se pueda cumplir.

---

## 7. Antes de publicar (revisión de 2 minutos)

- [ ] Nombre del negocio y logo correctos.
- [ ] WhatsApp abre el chat del negocio.
- [ ] Todos los precios coinciden con lo confirmado.
- [ ] Horario y ciudad correctos.
- [ ] El QR escanea y abre la tienda.
- [ ] El pedido de prueba llega completo por WhatsApp.
- [ ] El primer mes está pagado.
- [ ] El cliente aceptó las condiciones por escrito.

> Si algo falla, **no se publica**. Se corrige y se vuelve a probar.

---

## 8. Lo que NO se debe pedir

- Cédula, dirección de la casa o datos bancarios del cliente para la tienda.
- Claves de Nequi, Daviplata, WhatsApp o redes sociales.
- Datos de sus compradores.
- Información que no se vaya a usar.

Solo se piden los datos del negocio que aparecerán en la tienda y el
comprobante del pago del plan.
