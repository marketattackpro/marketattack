/* =========================================================================
   MARKETATTACK · Pruebas automáticas del motor (sin navegador)
   Carga un demo.js en un entorno simulado y comprueba la lógica.
   Uso:  node motor.test.js <ruta/al/demo.js>
   Sale con código 1 si alguna prueba falla.
   ========================================================================= */
const fs = require("fs");
const vm = require("vm");
const path = require("path");

const demoPath = process.argv[2] || path.join(__dirname, "..", "..", "02_DEMO", "assets", "demo.js");
const src = fs.readFileSync(demoPath, "utf8");

function cargar(source) {
  const store = {};
  const sb = {
    console, Date, Math, JSON, parseInt, parseFloat, isNaN, encodeURIComponent,
    document: { title: "" }
  };
  sb.window = sb;
  sb.localStorage = {
    getItem: (k) => (k in store ? store[k] : null),
    setItem: (k, v) => { store[k] = String(v); },
    removeItem: (k) => { delete store[k]; }
  };
  vm.createContext(sb);
  vm.runInContext(source, sb, { filename: demoPath });
  return sb;
}

const sb = cargar(src);
const CLIENTE = sb.MarketAttack.CLIENTE;

let pass = 0, fail = 0;
const eq = (a, b, msg) => { if (a === b) pass++; else { fail++; console.log(`  \u2717 ${msg}\n      esperado: ${b}\n      obtuve:   ${a}`); } };
const ok = (c, msg) => { if (c) pass++; else { fail++; console.log(`  \u2717 ${msg}`); } };
const noThrow = (fn, msg) => { try { fn(); pass++; } catch (e) { fail++; console.log(`  \u2717 ${msg}: ${e.message}`); } };

console.log(`\u25b8 Probando: ${demoPath}`);

/* 1) Detección de intención */
const base = [
  ["hola", "saludo"], ["menu", "menu"], ["que tienen", "menu"],
  ["cuanto vale", "menu"], ["horario", "horario"], ["a que hora abren", "horario"],
  ["donde quedan", "ubicacion"], ["cual es la direccion", "ubicacion"],
  ["promo", "promocion"], ["quiero la promo", "promocion"],
  ["quiero pedir un domicilio", "pedido"], ["como pago con tarjeta", "pago"],
  ["gracias", "gracias"], ["chao", "despedida"], ["xyzabc", "desconocido"]
];
base.forEach(([t, e]) => eq(sb.detectarIntencion(t), e, `detectarIntencion("${t}")`));

/* 2) El menú incluye todos los productos y precios del cliente */
const menuTxt = sb.obtenerMenu();
CLIENTE.menu.forEach((m) => {
  ok(menuTxt.includes(m.nombre), `el menú incluye "${m.nombre}"`);
  ok(menuTxt.includes(m.precio), `el menú incluye el precio "${m.precio}"`);
});
if (CLIENTE.promociones.length) {
  ok(menuTxt.includes(CLIENTE.promociones[0].texto), "el menú incluye la promoción");
}

/* 3) Un producto del menú dispara la intención "menu" */
const palabra = String(CLIENTE.menu[0].nombre).split(/\s+/).find((w) => w.length > 3) || "menu";
eq(sb.detectarIntencion(palabra.toLowerCase()), "menu", `producto "${palabra}" → menu`);

/* 4) La promoción NO rompe el chat aunque no haya promociones */
ok(typeof sb.responderConIntencion("promocion", "") === "string", "responderConIntencion('promocion') devuelve texto");
const guardado = CLIENTE.promociones;
CLIENTE.promociones = [];
noThrow(() => sb.responderConIntencion("promocion", "quiero la promo"), "promoción sin promociones no rompe");
CLIENTE.promociones = guardado;

/* 5) Generador de marketing */
const cont = sb.generarContenido("prueba de contenido");
ok(Array.isArray(cont) && cont.length >= 4, "generarContenido devuelve al menos 4 canales");
ok(cont.every((c) => c.canal && c.texto), "cada pieza tiene canal y texto");
ok(cont.some((c) => c.texto.includes(CLIENTE.nombreComercial)), "el contenido menciona el nombre del negocio");

/* 6) Almacenamiento de prospectos (mini-CRM) */
sb.MarketAttack.limpiarProspectos();
eq(sb.MarketAttack.leerProspectos().length, 0, "el CRM arranca vacío");
sb.MarketAttack.guardarListaProspectos([{ nombre: "Ana", telefono: "3001112233", estado: "nuevo" }]);
eq(sb.MarketAttack.leerProspectos().length, 1, "el CRM guarda y lee un prospecto");

/* 7) El título de la pestaña toma el nombre del negocio */
eq(sb.document.title, CLIENTE.nombreComercial + " \u00b7 Tienda", "document.title = nombre del negocio");

/* 8) Estado abierto/cerrado a partir del horario */
ok(typeof sb.estadoHorario === "function", "estadoHorario es función");
const lunesMediodia = new Date(2026, 9, 12, 12, 0, 0);   // lunes 12:00
const madrugada = new Date(2026, 9, 12, 3, 0, 0);        // lunes 3:00
const est = sb.estadoHorario(lunesMediodia);
ok(est && est.abierto === true, "a mediodía (lunes) está ABIERTO");
ok(sb.estadoHorario(madrugada).abierto === false, "a las 3:00 a. m. está CERRADO");
const horarioReal = CLIENTE.info.horario;
CLIENTE.info.horario = "texto sin ninguna hora";
eq(sb.estadoHorario(lunesMediodia), null, "horario no interpretable devuelve null (no miente)");
CLIENTE.info.horario = horarioReal;

/* 9) Compartir disponible */
ok(typeof sb.compartirTienda === "function", "compartirTienda es función");


console.log(`  ${fail === 0 ? "\u2713" : "\u2717"} ${pass} pruebas OK, ${fail} fallidas`);
process.exit(fail === 0 ? 0 : 1);
