# 🍔 MARKETATTACK — Tienda Demo IA

Demo funcional y reutilizable de la plataforma MarketAttack: atención al cliente,
captación de prospectos, mini-CRM, dashboard y generación de contenido de marketing.

---

## 1. Contenido del proyecto

```
02_DEMO/
├── index.html          → Landing profesional de MarketAttack (presentación + enlace a la demo)
├── tienda.html         → La Tienda Demo IA (chat + panel + dashboard + marketing)
├── demo-server.sh      → Publica la demo en tu red local (para verla desde el celular)
│                        Uso: bash demo-server.sh  |  detener: Ctrl+C
└── assets/
    ├── style.css       → Diseño compartido (responsivo: PC y móvil)
    └── demo.js         → ⭐ BASE REUTILIZABLE: configuración del negocio + lógica
```

## 2. Cómo abrir la demo

### Opción A — En este PC (más simple)
- Doble clic en `tienda.html` o `index.html`.
- O en terminal: `xdg-open tienda.html`

### Opción B — Desde el celular (para mostrar en visitas)
1. En terminal: `bash demo-server.sh`
2. Conecta tu celular a la **misma red Wi-Fi** que el PC.
3. Abre en el celular la dirección que imprime el script (ej: `http://192.168.1.x:8000`).
4. Para detener: `Ctrl+C` en el terminal.

## 3. Cómo se usa (demo de 2 minutos)
1. Abre `tienda.html`.
2. En el chat pregunta: *"¿qué venden?"*, *"¿horarios?"* o pide *"la promo"*.
3. La IA responde con el menú y datos del negocio.
4. Si pide la promo, la conversación captura **nombre → teléfono → interés**.
5. En la pestaña **Panel** quedará registrado el prospecto (estados Nuevo → Contactado → Vendido).
6. Habilitando **Exportar CSV** descargas los prospectos.
7. La pestaña **Marketing IA** genera textos para Instagram, Facebook, WhatsApp e historias.

## 4. Cómo crear un cliente nuevo (sistema base + configuración)

Todo se configura editando el objeto `CLIENTE` en `assets/demo.js`:

```js
const CLIENTE = {
  nombreComercial: "Market Burger",   // nombre del negocio
  nombreInterno: "marketburger",      // prefijo de datos (único por cliente)
  whatsapp: "573209226563",           // número de contacto
  marca: { tagline: "...", tono: "amigable y cercano" },
  info: { horario: "...", ubicacion: "...", contacto: "..." },
  menu: [{ nombre, precio, desc }, ...],
  promociones: [{ titulo, texto }, ...],
  preguntasFrecuentes: [{ p, r }, ...]
};
```

Reglas:
- Cada cliente usa su propio `nombreInterno` → sus prospectos quedan **aislados** (multicliente).
- No hace falta tocar el resto del código para un cliente estándar.
- Para un negocio muy distinto (ej: barbería), se cambian texto del menú por "catálogo de servicios"; la lógica es igual.

## 5. Estado técnico y hoja de ruta

| Pieza | Estado |
|---|---|
| Chat con captura de datos | ✅ Funcional (reglas, demo) |
| Panel mini-CRM + estados + CSV | ✅ Funcional |
| Dashboard de métricas | ✅ Funcional |
| Marketing IA (plantillas) | ✅ Demostrativo |
| Landing responsable | ✅ Funcional |
| Publicación en red local (móvil) | ✅ Funcional |
| WhatsApp Business API (real) | 🔜 V4 · primer cliente |
| IA real (API comercial) | 🔜 V4+ |
| Base de datos real (PostgreSQL) | 🔜 MVP |
| Autenticación/multicliente en servidor | 🔜 Después |

## 6. Notas de seguridad y datos (desde ya)
- Los prospectos de esta demo viven en el **navegador (localStorage)** — son datos de prueba.
- En el producto real los datos personales de clientes se protegen conforme a la **Ley 1581 de 2012** (Colombia): consentimiento al capturar, acceso y eliminación.
- La demo es para validar flujo y mensaje comercial; la infraestructura productiva (VPS, Postgres, HTTPS) llega con el primer cliente.