#!/bin/bash
# ═══════════════════════════════════════════════════════════
#  PRODUCTO MARKETATTACK — para vender por Telegram
#  /producto  → el catálogo
#  /oferta   → el pitch corto para mandar a un cliente
#  /precios  → la tabla de precios
# ═══════════════════════════════════════════════════════════

catalogo(){
cat <<'CAT'
🟠 <b>MARKETATTACK</b> — tu negocio con IA trabajando 24/7

<b>Qué es</b>
Una plataforma que responde a tus clientes, capta prospectos y
te da un panel para ver todo. Se instala en tu negocio y trabaja
solo, también de noche.

<b>Lo que incluye</b>
• Chat inteligente que atiende y cotiza solo
• Captación de prospectos (los que preguntan y no compran)
• Mini-CRM: ves quién preguntó, qué pidió y cuánto vale
• Dashboard con las métricas de tu negocio
• Generador de contenido para redes, desde una idea
• Tu propia tienda con QR y enlace de un clic

<b>Para quién</b>
Restaurantes, tiendas de barrio, talleres, clínicas, inmobiliarias,
salones de belleza, ferroviarios y cualquier negocio que hoy
responde mensajes a mano.

<b>Cómo se ve</b>
  https://marketattack.netlify.app/tienda.html
  → Toca "Probar la demo" y escríbele. Funciona.

<b>Instalación</b>
En 24 horas. Sin instalar nada raro. Te lo dejamos andando
y te enseñamos a usarlo.

<b>Precios</b>
  🟢 Esencial — <b>$450.000</b>/mes
     Chat + prospectos + panel. Hasta 500 conversaciones.

  🔵 Profesional — <b>$850.000</b>/mes  ⭐ el más elegido
     Todo lo anterior + generación de contenido + QR ilimitado.

  🟣 Escala — <b>$1.400.000</b>/mes
     Todo + multi-sucursal + acompañamiento mensual.

<b>Sin permanencia</b>
Pagas el mes. Si no te sirve, te vas. Sin letra pequeña.

<b>¿Lo probamos?</b>
Escríbeme "DEMO" y te mando el enlace directo de tu negocio
en 10 minutos.
CAT
}

oferta(){
cat <<'OF'
<b>Hola 👋</b>

Te escribo de <b>MARKETATTACK</b>. Te pongo la versión corta:

Hoy, cuando un cliente te escribe fuera de horario, ese mensaje
se queda sin respuesta. Al día siguiente ya se fue a otro.

Nosotros montamos una IA que contesta por ti las 24 horas,
captura a los que preguntan y te los deja ordenados en un panel
con cuánto vale cada uno.

Te lo dejamos funcionando en 24 horas.
Y antes de que pagues nada, lo pruebas con tu propio negocio.

¿Te lo muestro? Dime "sí" y te mando el enlace.
OF
}

precios(){
cat <<'PR'
💰 <b>Precios MARKETATTACK</b>

🟢 <b>Esencial — $450.000/mes</b>
   Chat con IA · prospectos · panel · 500 conversaciones

🔵 <b>Profesional — $850.000/mes</b> ⭐
   Todo lo de Esencial + contenido para redes + QR ilimitado

🟣 <b>Escala — $1.400.000/mes</b>
   Todo lo anterior + varias sedes + acompañamiento

Todos incluyen: instalación, capacitación y soporte por WhatsApp.
Sin permanencia. Si no te sirve, cancelas.

<i>Precios en pesos colombianos. Factura issued electrónicamente.</i>
PR
}
