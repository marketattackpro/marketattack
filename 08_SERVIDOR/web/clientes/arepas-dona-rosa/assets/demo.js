/* =========================================================================
   MARKETATTACK — TIENDA DEMO IA
   Lógica compartida (base reutilizable).
   Para un CLIENTE NUEVO solo se cambia el objeto CLIENTE abajo.
   ========================================================================= */

/* -------------------------------------------------------------------------
   1. CONFIGURACIÓN DEL CLIENTE (cambiar por cada negocio)
   ------------------------------------------------------------------------- */
const CLIENTE = {
  "nombreComercial": "Arepas Doña Rosa",
  "nombreInterno": "arepas-dona-rosa",
  "whatsapp": "3001234567",
  "marca": {
    "tagline": "Las arepas del barrio, hechas a mano",
    "tono": "amigable y cercano"
  },
  "info": {
    "horario": "Lunes a domingo de 6:00 a. m. a 8:00 p. m.",
    "ubicacion": "Carrera 7 # 23-45, Bosa La Esperanza, Bogotá",
    "contacto": "Pedidos por WhatsApp: 300 123 4567"
  },
  "menu": [
    {
      "nombre": "Arepas con Queso",
      "precio": "$5.000",
      "desc": "Arepa de maíz asada, queso costeño fundido"
    },
    {
      "nombre": "Arepas Rellena de Pollo",
      "precio": "$9.000",
      "desc": "Pollo desmechado, aguacate y salsa de la casa"
    },
    {
      "nombre": "Arepas con Chicharrón",
      "precio": "$8.000",
      "desc": "Chicharron crujiente con suero costeño"
    },
    {
      "nombre": "Arepas Mixta",
      "precio": "$12.000",
      "desc": "Pollo + chicharrón + queso (grande)"
    },
    {
      "nombre": "Jugo de Corozo",
      "precio": "$4.000",
      "desc": "Natural, servido frío"
    },
    {
      "nombre": "Café con leche",
      "precio": "$3.500",
      "desc": "Preparado al momento"
    }
  ],
  "promociones": [
    {
      "titulo": "PROMO",
      "texto": "2x1 los martes. Domicilio gratis sobre $20.000."
    }
  ],
  "preguntasFrecuentes": [
    {
      "p": "¿Hacen domicilio?",
      "r": "Sí, llegamos a toda Bosa y Bosa Centro en 25 minutos."
    },
    {
      "p": "¿Cómo es el pago?",
      "r": "Efectivo, Nequi/Daviplata o tarjeta."
    }
  ]
};;

/* Simula una IA real: junto a este demo se conectará un modelo (V4+).
   Aquí usamos reglas y plantillas para mostrar el flujo completo y barato. */
const KEY = "prospectos_" + CLIENTE.nombreInterno;

const ETAPAS_CAPTURA = ["nombre", "telefono", "interes"];

/* -------------------------------------------------------------------------
   2. ESTADO DE LA SESIÓN
   ------------------------------------------------------------------------- */
let etapaCaptura = null;         // null | "nombre" | "telefono" | "interes"
let prospectoParcial = {};
let conversacion = [];

/* -------------------------------------------------------------------------
   3. MOTOR DE RESPUESTAS (reglas + plantillas)
   ------------------------------------------------------------------------- */
const RESPONSES = {
  saludo: [
    "¡Hola! Bienvenido a {negocio} 😊 Soy el asistente virtual. Te ayudo con el menú, precios, horarios, ubicación y promociones. ¿Qué deseas saber?",
    "¡Hola! 😊 Gracias por escribirnos. ¿En qué podemos ayudarte? Puedes preguntar por el menú o las promociones."
  ],
  despedida: ["¡Gracias por escribirnos! Que tengas un excelente día 🌟", "¡Fue un gusto atenderte! Estamos para lo que necesites 🙌"],
  gracias: ["¡Con gusto! 😊 ¿Quieres pedir algo o te interesa alguna promoción?", "¡Para eso estamos! 🍽️ ¿Te preparo una orden?"],
  default: [
    "No estoy seguro de entenderte 😅. Por ejemplo, puedo decirte el menú, los precios, el horario o contarte las promociones. ¿Sobre qué quieres saber?"
  ]
};

function rellenar(texto, extra) {
  let t = texto.replace("{negocio}", CLIENTE.nombreComercial);
  if (extra) for (const k in extra) t = t.replaceAll("{" + k + "}", extra[k]);
  return t;
}

function obtenerMenu() {
  const lineas = CLIENTE.menu.map(m => "🍽️ " + m.nombre + " — " + m.precio + "\n   " + m.desc);
  return "Nuestro menú:\n" + lineas.join("\n") + "\n\n" + promocionActual() + "\n¿Te interesa alguna de estas opciones? 😊";
}

function promocionActual() {
  if (!CLIENTE.promociones.length) return "";
  const p = CLIENTE.promociones[0];
  return "🎉 " + p.titulo + ": " + p.texto;
}

function detectarIntencion(texto) {
  const t = texto.toLowerCase();
  if (/(hola|buenas|buenos días|buenas tardes|buenas noches|hey|qué más|bienvenido)/.test(t)) return "saludo";
  const nombresMenu = (CLIENTE.menu || []).map(m => String(m.nombre || "").toLowerCase());
  const mencionaProducto = nombresMenu.some(n => n && n.split(/\s+/).some(w => w.length > 3 && t.includes(w)));
  if (/(menu|carta|comida|precios|precio|productos|bebida|plato|cu[aá]nto (cuesta|vale|es|est[aá])|\bvale\b|qu[eé] venden|que venden|qu[eé] tienen|que tienen)/.test(t) || mencionaProducto) return "menu";
  if (/(horario|horarios|abren|cierran|abierto|cuándo abren)/.test(t)) return "horario";
  if (/(ubicación|ubicacion|dirección|direccion|dónde|donde|cuál es la ubicación|mapa)/.test(t)) return "ubicacion";
  if (/(promo|promoción|promocion|oferta|descuento|especial|combo.*promo|viernes)/.test(t)) return "promocion";
  if (/(reparto|cuánto demora|cuanto demora|demora|llega|tiempo d)/.test(t)) return "reparto";
  if (/(pago|pagar|tarjeta|efectivo|transferencia)/.test(t)) return "pago";
  if (/(pedir|pedido|domicilio|envio|envío|comprar|reservar|reserva|cotizar)/.test(t)) return "pedido";
  if (/(vegetariano|veggie|opciones sin carne|sin carne)/.test(t)) return "vegetariano";
  if (/(gracias|muchas gracias|perfecto|ok|de acuerdo|genial|excelente)/.test(t)) return "gracias";
  if (/(adiós|adios|chao|hasta luego|nos vemos|gracias.*adios)/.test(t)) return "despedida";
  return "desconocido";
}

function responderConIntencion(intencion, texto) {
  switch (intencion) {
    case "saludo": return aleatorio(RESPONSES.saludo);
    case "menu": return obtenerMenu();
    case "horario": return "📍 Nuestro horario:\n" + CLIENTE.info.horario + "\n\n¿Quieres que te cuente el menú o las promociones?";
    case "ubicacion": return "📍 Estamos en: " + CLIENTE.info.ubicacion + "\n\n" + CLIENTE.info.contacto;
    case "promocion": {
      if (!CLIENTE.promociones || !CLIENTE.promociones.length)
        return "Por ahora no tenemos promociones activas 😊, pero con gusto te cuento el menú. ¿Qué te gustaría saber?";
      return iniciarCaptura("🎉 " + CLIENTE.promociones[0].titulo + ": " + CLIENTE.promociones[0].texto);
    }
    case "pedido": return "¡Claro! 🛵 Hacemos pedidos y domicilios.\n\n" + obtenerMenu() + "\n\nCuéntame qué te gustaría pedir.";
    case "pago": return "💳 Aceptamos efectivo, tarjeta y por transferencia. Al confirmar tu pedido te indicamos todos los medios.";
    case "reparto": return preguntasRapidas("reparto");
    case "vegetariano": return preguntasRapidas("vegetariano");
    case "gracias": return aleatorio(RESPONSES.gracias);
    case "despedida": return aleatorio(RESPONSES.despedida);
    default: {
      // Si el cliente menciona algo que parece un interés/compra, invita a capturar
      if (/(promo|oferta|quiero|me interesa|cuánto|cuanto|comprar)/.test(texto.toLowerCase())) {
        return iniciarCaptura(texto.trim());
      }
      return aleatorio(RESPONSES.default);
    }
  }
}

function preguntasRapidas(tema) {
  const r = CLIENTE.preguntasFrecuentes.find(r => tema === "reparto" ? r.p.includes("domicilio") : r.p.includes("vegetariano"));
  return r ? r.r : "Déjame verificarlo contigo 😊";
}

function iniciarCaptura(interes) {
  etapaCaptura = "nombre";
  prospectoParcial = { interes };
  return "¡Perfecto! 🎉 Para registrar tu interés y que el dueño te contacte rápido, necesito primero tu **NOMBRE**, por favor 😊";
}

function extraerNumero(texto) {
  const nums = texto.replace(/[^\d+]/g, "");
  return nums.length >= 7 ? nums.slice(0, 13) : null;
}

function guardarProspecto() {
  const p = { ...prospectoParcial, estado: "nuevo", fecha: new Date().toLocaleString("es-CO") };
  const lista = leerProspectos();
  lista.push(p);
  localStorage.setItem(KEY, JSON.stringify(lista));
  const nombre = prospectoParcial.nombre;
  etapaCaptura = null;
  prospectoParcial = {};
  return "✅ ¡Listo " + nombre + "! Tu información quedó registrada y el restaurante ya recibió tu oportunidad. En breve te contactamos por WhatsApp. ¡Gracias por preferir " + CLIENTE.nombreComercial + "! 🍽️";
}

/* -------------------------------------------------------------------------
   4. ALMACENAMIENTO DE PROSPECTOS (mini-CRM)
   ------------------------------------------------------------------------- */
function leerProspectos() {
  try { return JSON.parse(localStorage.getItem(KEY)) || []; } catch (e) { return []; }
}

function guardarListaProspectos(lista) {
  localStorage.setItem(KEY, JSON.stringify(lista));
}

function cambiarEstadoProspecto(id, nuevoEstado) {
  const lista = leerProspectos();
  const p = lista.find(x => x.id === id);
  if (p) { p.estado = nuevoEstado; guardarListaProspectos(lista); }
}

function eliminarProspecto(id) {
  guardarListaProspectos(leerProspectos().filter(x => x.id !== id));
}

function limpiarProspectos() {
  localStorage.removeItem(KEY);
}

/* -------------------------------------------------------------------------
   5. FUNCIONALIDADES COMPARTIDAS
   ------------------------------------------------------------------------- */
function aleatorio(arr) { return arr[Math.floor(Math.random() * arr.length)]; }

function idsUnicos() {
  const lista = leerProspectos();
  lista.forEach((p, i) => { if (!p.id) p.id = Date.now() + "-" + i; });
  guardarListaProspectos(lista);
  return lista;
}

function templateProps() {
  return {
    negocio: CLIENTE.nombreComercial,
    whatsapp: CLIENTE.whatsapp,
    menu: CLIENTE.menu,
    inf: CLIENTE.info,
    promo: CLIENTE.promociones[0]
  };
}

/* -------------------------------------------------------------------------
   6. GENERADOR DE MARKETING (plantillas por canal)
   ------------------------------------------------------------------------- */
function generarContenido(idea) {
  const t = templateProps();
  return [
    {
      canal: "📸 Instagram",
      texto: `🔥 ¡ALERTA DE PROMO! 🔥\n\n${idea}\n\n¿No quieres perderte esta oferta? Escríbenos YA al WhatsApp y asegura la tuya. 🍽️🥤\n\n📍 ${t.inf.ubicacion}\n⏰ ${t.inf.horario}\n\n#Promo #${CLIENTE.nombreComercial.replace(/\s/g, "")}`
    },
    {
      canal: "📘 Facebook",
      texto: `📌 Estamos de promoción este fin de semana.\n\n${idea}\n\nPide por inbox, déjanos tu nombre y teléfono, y te contactamos en minutos. 🚀\n\n${CLIENTE.nombreComercial} — Atención rápida y domicilios.`
    },
    {
      canal: "💬 WhatsApp (broadcast)",
      texto: `Hola 👋 Somos ${CLIENTE.nombreComercial}. Tenemos una oferta especialmente para ti:\n\n${idea}\n\n¡Responde este mensaje con tu nombre y teléfono para reservar la tuya! 🍽️`
    },
    {
      canal: "🦋 Historias (CTA)",
      texto: `🔥 Quiero la promo → [ENLACE WHATSAPP]\n\n${idea}\n\nSolo por tiempo limitado ⏰`
    }
  ];
}

/* Exportar funciones útiles para páginas nuevas */
window.MarketAttack = {
  CLIENTE,
  KEY,
  ETAPAS_CAPTURA,
  leerProspectos,
  guardarListaProspectos,
  cambiarEstadoProspecto,
  eliminarProspecto,
  limpiarProspectos,
  idsUnicos,
  generarContenido,
  generarIdea: () => CLIENTE.promociones[0] ? CLIENTE.promociones[0].texto : "",
  estadoHorario,
  compartirTienda
};

/* Título de la pestaña = nombre del negocio (no el genérico del motor) */
if (typeof document !== "undefined" && CLIENTE && CLIENTE.nombreComercial) {
  document.title = CLIENTE.nombreComercial + " · Tienda";
}

/* =========================================================================
   ESTADO "ABIERTO / CERRADO" EN VIVO (a partir del horario del negocio)
   Devuelve {abierto, detalle} o null si no se puede interpretar el horario.
   ========================================================================= */
const _DIAS = { domingo: 0, lunes: 1, martes: 2, miercoles: 3, jueves: 4, viernes: 5, sabado: 6,
                dom: 0, lun: 1, mar: 2, mie: 3, jue: 4, vie: 5, sab: 6 };
const _DIAS_RE = "domingo|lunes|martes|miercoles|jueves|viernes|sabado|dom|lun|mar|mie|jue|vie|sab";

function _sinAcentos(s) { return s.normalize("NFD").replace(/[\u0300-\u036f]/g, ""); }
function _diaNum(p) { return _DIAS[String(p).toLowerCase()] ?? null; }

function _aMinutos(h1, mm1, mer1, h2, mm2, mer2) {
  const toMin = (h, mm, mer) => {
    h = +h; mm = mm ? +mm : 0;
    if (mer === "pm" && h < 12) h += 12;
    if (mer === "am" && h === 12) h = 0;
    return h * 60 + mm;
  };
  const s = toMin(h1, mm1, mer1);
  let e = toMin(h2, mm2, mer2);
  // sin a.m./p.m. y con forma 12h donde el fin parece menor: asumimos tarde
  if (!mer1 && !mer2 && e <= s && +h2 <= 12) e += 12 * 60;
  return { s, e };
}

function _fmtHora(min) {
  min = ((min % 1440) + 1440) % 1440;
  let h = Math.floor(min / 60), m = min % 60;
  const mer = h < 12 ? "a. m." : "p. m.";
  let h12 = h % 12; if (h12 === 0) h12 = 12;
  return h12 + ":" + (m < 10 ? "0" + m : m) + " " + mer;
}

function estadoHorario(ahora) {
  ahora = ahora || new Date();
  const raw = (CLIENTE.info && CLIENTE.info.horario) ? CLIENTE.info.horario : "";
  if (!raw) return null;
  let t = _sinAcentos(raw.toLowerCase())
    .replace(/\ba\.?\s*m\.?/g, "am")
    .replace(/\bp\.?\s*m\.?/g, "pm")
    .replace(/[–—]/g, "-");

  // --- días ---
  let dias = null;
  if (/todos los dias|\btodos\b/.test(t)) dias = [0, 1, 2, 3, 4, 5, 6];
  if (!dias) {
    const rango = t.match(new RegExp("\\b(" + _DIAS_RE + ")\\b\\s*(?:a|hasta)\\s*\\b(" + _DIAS_RE + ")\\b"));
    if (rango) {
      const a = _diaNum(rango[1]), b = _diaNum(rango[2]);
      if (a !== null && b !== null) {
        dias = []; let d = a;
        for (let i = 0; i < 7; i++) { dias.push(d); if (d === b) break; d = (d + 1) % 7; }
      }
    } else {
      const set = new Set();
      (t.match(new RegExp("\\b(" + _DIAS_RE + ")\\b", "g")) || []).forEach(tk => {
        const n = _diaNum(tk); if (n !== null) set.add(n);
      });
      if (set.size) dias = [...set];
    }
  }

  // --- horas ---
  const re = /(\d{1,2})(?::(\d{2}))?\s*(am|pm)?\s*(?:a|hasta|-|a las)\s*(\d{1,2})(?::(\d{2}))?\s*(am|pm)?/g;
  const rangos = [];
  let m;
  while ((m = re.exec(t)) !== null) {
    rangos.push(_aMinutos(m[1], m[2], m[3], m[4], m[5], m[6]));
  }
  if (!rangos.length) return null;

  const dow = ahora.getDay();
  const ahoraMin = ahora.getHours() * 60 + ahora.getMinutes();
  const aplicaHoy = !dias || dias.includes(dow);

  let abierto = false, cierraHoy = null, abreHoy = null;
  if (aplicaHoy) {
    for (const r of rangos) {
      if (r.e >= r.s) {
        if (ahoraMin >= r.s && ahoraMin < r.e) abierto = true;
        if (r.s > ahoraMin && (abreHoy === null || r.s < abreHoy)) abreHoy = r.s;
        if (r.e > ahoraMin && (cierraHoy === null || r.e < cierraHoy)) cierraHoy = r.e;
      } else {
        if (ahoraMin >= r.s || ahoraMin < r.e) abierto = true;
        if (ahoraMin < r.e) cierraHoy = r.e;
      }
    }
  }

  let detalle;
  if (abierto) detalle = (cierraHoy !== null) ? "Cierra " + _fmtHora(cierraHoy) : "Pedidos abiertos";
  else if (aplicaHoy && abreHoy !== null) detalle = "Abre " + _fmtHora(abreHoy);
  else {
    // busca el próximo día con horario
    let siguiente = null;
    for (let k = 1; k <= 7; k++) {
      const dk = (dow + k) % 7;
      if (!dias || dias.includes(dk)) { siguiente = rangos[0].s; break; }
    }
    detalle = (siguiente !== null) ? "Abre " + _fmtHora(siguiente) : "";
  }
  return { abierto, detalle };
}

/* =========================================================================
   UI opcional: estado, compartir y mapa (solo si existen los contenedores)
   ========================================================================= */
function compartirTienda() {
  const url = (typeof location !== "undefined") ? location.href : "";
  const titulo = CLIENTE.nombreComercial;
  const texto = titulo + (CLIENTE.marca && CLIENTE.marca.tagline ? " — " + CLIENTE.marca.tagline : "") + "\n" + url;
  if (typeof navigator !== "undefined" && navigator.share) {
    navigator.share({ title: titulo, text: texto, url }).catch(() => {});
  } else if (typeof window !== "undefined") {
    window.open("https://wa.me/?text=" + encodeURIComponent(texto), "_blank");
  }
}

function _iniciarUI() {
  if (typeof document === "undefined" || typeof document.getElementById !== "function") return;
  const estadoEl = document.getElementById("ma-estado");
  if (estadoEl) {
    const pintar = () => {
      const e = estadoHorario(new Date());
      if (!e) { estadoEl.style.display = "none"; return; }
      estadoEl.style.display = "";
      estadoEl.className = "ma-estado " + (e.abierto ? "abierto" : "cerrado");
      estadoEl.textContent = (e.abierto ? "🟢 Abierto ahora" : "🔴 Cerrado ahora")
        + (e.detalle ? " · " + e.detalle : "");
    };
    pintar();
    setInterval(pintar, 60000);
  }
  const shareEl = document.getElementById("ma-compartir");
  if (shareEl && typeof shareEl.addEventListener === "function") {
    shareEl.addEventListener("click", (ev) => { ev.preventDefault(); compartirTienda(); });
  }
  const mapaEl = document.getElementById("ma-mapa");
  if (mapaEl && CLIENTE.info && CLIENTE.info.ubicacion) {
    const q = encodeURIComponent(CLIENTE.info.ubicacion);
    mapaEl.innerHTML = '<iframe title="Ubicación" loading="lazy" '
      + 'referrerpolicy="no-referrer-when-downgrade" '
      + 'style="width:100%;height:300px;border:0;border-radius:14px" '
      + 'src="https://www.google.com/maps?q=' + q + '&output=embed"></iframe>';
  }
}

if (typeof document !== "undefined" && typeof document.addEventListener === "function") {
  document.addEventListener("DOMContentLoaded", _iniciarUI);
}