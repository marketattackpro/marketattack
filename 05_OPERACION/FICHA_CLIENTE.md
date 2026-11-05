# FICHA DEL CLIENTE — datos para armar la tienda

La solicitud completa está en `05_OPERACION/SOLICITUD_INICIO_CLIENTE.md`.
La versión breve está en `05_OPERACION/SOLICITUD_CORTA.md`.

En Telegram se envían con `/solicitud` y `/solicitud corta`.

---

## Ficha interna (para el proyecto)

```
Negocio:
Slug:
Contacto / dueño:
WhatsApp:
Plan:
Valor mensual:
Fecha de pago:
Vence:
Ciudad / barrio:
Dirección o referencia:
Horario:
Domicilio (zonas y costo):
Tiempo de entrega:
Pedido mínimo:
Métodos de pago:
Titular de la cuenta (opcional):
Promoción:
Redes sociales:
Logo / fotos:
Garantías o cambios:
Reglas especiales:
Autorización de marca y pedidos:
Observaciones:
```

---

## Reglas al recibir los datos

- **WhatsApp siempre con 57** y sin espacios: `573001234567`.
- Los precios van **sin puntos ni signos**: `12000`, no `$12.000`.
- Cada producto se escribe así: `Nombre|Precio|Descripción corta`.
- Si el cliente no da descripción, se escribe algo simple y útil.
- Si no da logo, se usa el ícono de MARKETATTACK; nunca se deja vacío.
- Antes de publicar, **confirma por escrito** que los precios, el horario y
  el WhatsApp están bien.
- Si el cliente manda los datos por Telegram, quedan guardados en
  `05_CLIENTES/_entradas/` (ver `RECEPCION_DATOS_TELEGRAM.md`).
