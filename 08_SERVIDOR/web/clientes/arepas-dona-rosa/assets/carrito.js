/* ============================================================================
   🛒 CARRITO + MÉTODOS DE PAGO + REDES SOCIALES — MARKETATTACK
   Módulo autocontenido e inyectable. Cero dependencia de la estructura del chat.
   ============================================================================ */
(function () {
  "use strict";

  if (document.getElementById("carrito-root")) return;

  var CARRITO = [];
  var medioSel = "";

  var _MC = window.MarketAttack || {};
  var _CL = _MC.CLIENTE || {};
  var _waNum = String(_CL.whatsapp || "").replace(/[^\d]/g, "");
  if (_waNum.length === 10 && _waNum.startsWith("3")) _waNum = "57" + _waNum;
  var _waLink = "https://wa.me/" + _waNum + "?text=" + encodeURIComponent("Hola, quiero pedir");
  var _waTexto = "💬 WhatsApp: " + (_waNum.length === 12 ? _waNum.slice(2).replace(/(\d{3})(\d{3})(\d{4})/, "$1 $2 $3") : _waNum);

  function total() {
    return CARRITO.reduce(function (ac, i) { return ac + (parsePrecio(i.precio) * (i.cant || 1)); }, 0);
  }
  function contar() {
    return CARRITO.reduce(function (ac, i) { return ac + (i.cant || 1); }, 0);
  }
  function parsePrecio(s) {
    var n = parseInt(String(s).replace(/[^0-9]/g, ""), 10);
    return isNaN(n) ? 0 : n;
  }
  function moneda(n) { return "$" + n.toLocaleString("es-CO"); }

  var css = document.createElement("style");
  css.textContent = [
    "#carrito-root{position:fixed;bottom:78px;right:16px;z-index:99999;font-family:system-ui,sans-serif;max-width:94vw}",
    "#carrito-boton{background:#e63946;color:#fff;border:none;border-radius:999px;padding:13px 18px;font-size:15px;font-weight:700;cursor:pointer;box-shadow:0 4px 14px rgba(0,0,0,.3);display:flex;align-items:center;gap:8px}",
    "#carrito-boton .n{background:#fff;color:#e63946;border-radius:999px;padding:0 9px;font-size:13px;font-weight:800}",
    "#carrito-panel{position:fixed;bottom:78px;right:18px;width:min(340px,92vw);max-height:70vh;overflow:auto;background:#fff;border-radius:14px;box-shadow:0 10px 30px rgba(0,0,0,.3);padding:16px;display:none}",
    "#carrito-panel.abierto{display:block}",
    "#carrito-panel h3{margin:0 0 10px;font-size:16px;color:#111}",
    ".car-item{display:flex;justify-content:space-between;align-items:center;padding:7px 0;border-bottom:1px dashed #eee;font-size:13.5px;gap:8px}",
    ".car-item .lbl{flex:1;color:#222}",
    ".car-item .prec{font-weight:700;color:#e63946;white-space:nowrap}",
    ".car-q{display:flex;align-items:center;gap:6px;color:#333}",
    ".car-q button{background:#f0f0f0;border:none;border-radius:6px;width:23px;height:23px;cursor:pointer;font-weight:700}",
    "#carrito-total{font-weight:800;font-size:16px;text-align:right;margin:10px 0;color:#111}",
    "#carrito-pago{width:100%;background:#27ae60;color:#fff;border:none;border-radius:10px;padding:12px;font-size:15px;font-weight:700;cursor:pointer;display:none}",
    "#carrito-medios{margin-top:12px;border-top:1px solid #eee;padding-top:10px}",
    "#carrito-medios h4{margin:0 0 8px;font-size:14px;color:#333}",
    ".medio{display:flex;align-items:center;justify-content:space-between;border:1.5px solid #e0e0e0;border-radius:9px;padding:9px 12px;margin:5px 0;cursor:pointer;font-size:13.5px}",
    ".medio.seleccionado{border-color:#27ae60;background:#eafaf1}",
    ".medio .sel{width:14px;height:14px;border-radius:50%;border:2px solid #ccc;display:inline-block}",
    ".medio.seleccionado .sel{border-color:#27ae60;background:#27ae60}",
    "#carrito-confirmar{width:100%;background:#e63946;color:#fff;border:none;border-radius:10px;padding:12px;font-size:15px;font-weight:700;cursor:pointer;margin-top:8px;display:none}",
    "#carrito-ok{margin-top:10px;background:#eafaf1;border:1px solid #27ae60;border-radius:9px;padding:11px;font-size:13.5px;color:#145a2b;display:none}",
    "#carrito-vacio{color:#999;font-size:13px;text-align:center;padding:14px 0}",
    "#carrito-redes{margin-top:12px;border-top:1px solid #eee;padding-top:10px}",
    "#carrito-redes h4{margin:0 0 8px;font-size:14px;color:#333}",
    ".red-btna{display:block;width:100%;text-align:left;background:#f5f5f5;border:none;border-radius:8px;padding:9px 11px;margin:4px 0;cursor:pointer;font-size:13px;color:#222}",
    ".red-btna:hover{background:#ececec}"
  ].join("\n");
  (document.head || document.documentElement).appendChild(css);

  var root = document.createElement("div");
  root.id = "carrito-root";
  root.innerHTML =
    '<div id="carrito-panel">' +
    '  <h3>🛒 Tu pedido</h3>' +
    '  <div id="carrito-items"><p id="carrito-vacio">Tu carrito está vacío. Elige algo del menú 👇</p></div>' +
    '  <div id="carrito-total" style="display:none">Total: <span id="carrito-total-val">$0</span></div>' +
    '  <button id="carrito-pago">💳 Elegir método de pago</button>' +
    '  <div id="carrito-medios" style="display:none">' +
    '    <h4>¿Cómo vas a pagar?</h4>' +
    '    <div class="medio" data-medio="Efectivo al recibir"><span>💵 Efectivo al recibir</span><span class="sel"></span></div>' +
    '    <div class="medio" data-medio="Tarjeta débito/crédito"><span>💳 Tarjeta (débito/crédito)</span><span class="sel"></span></div>' +
    '    <div class="medio" data-medio="Nequi o transferencia"><span>🏦 Nequi / transferencia</span><span class="sel"></span></div>' +
    '  </div>' +
    '  <button id="carrito-confirmar">✅ Confirmar pedido</button>' +
    '  <div id="carrito-ok"></div>' +
    '  <div id="carrito-redes">' +
    '    <h4>📲 Síguenos y pide por redes</h4>' +
    '    <button class="red-btna" data-red="' + _waLink + '">' + _waTexto + '</button>' +
    '    <button class="red-btna" data-red="https://instagram.com">📸 Instagram</button>' +
    '    <button class="red-btna" data-red="https://facebook.com">📘 Facebook</button>' +
    '    <button class="red-btna" data-red="https://tiktok.com">🎵 TikTok</button>' +
    '  </div>' +
    '</div>' +
    '<button id="carrito-boton">🛒 Pedido <span class="n" id="carrito-cont">0</span></button>';

  document.body.appendChild(root);

  var panel = document.getElementById("carrito-panel");
  var itemsEl = document.getElementById("carrito-items");
  var contEl = document.getElementById("carrito-cont");
  var totalEl = document.getElementById("carrito-total");
  var totalVal = document.getElementById("carrito-total-val");
  var pagoBtn = document.getElementById("carrito-pago");
  var mediosEl = document.getElementById("carrito-medios");
  var confirmarBtn = document.getElementById("carrito-confirmar");
  var okEl = document.getElementById("carrito-ok");

  function render() {
    contEl.textContent = contar();
    if (CARRITO.length === 0) {
      itemsEl.innerHTML = '<p id="carrito-vacio">Tu carrito está vacío. Elige algo del menú 👇</p>';
      totalEl.style.display = "none";
      pagoBtn.style.display = "none";
      mediosEl.style.display = "none";
      confirmarBtn.style.display = "none";
      okEl.style.display = "none";
      return;
    }
    itemsEl.innerHTML = CARRITO.map(function (i, idx) {
      return '<div class="car-item">' +
        '<span class="lbl">' + i.nombre + '</span>' +
        '<span class="prec">' + moneda(parsePrecio(i.precio) * (i.cant || 1)) + '</span>' +
        '<span class="car-q"><button data-menos="' + idx + '">−</button> ' + (i.cant || 1) + ' <button data-mas="' + idx + '">+</button></span>' +
        '</div>';
    }).join("");
    totalVal.textContent = moneda(total());
    totalEl.style.display = "block";
    pagoBtn.style.display = "block";
    okEl.style.display = "none";
  }

  itemsEl.addEventListener("click", function (e) {
    var mas = e.target.getAttribute("data-mas");
    var menos = e.target.getAttribute("data-menos");
    if (mas !== null) { CARRITO[+mas].cant = (CARRITO[+mas].cant || 1) + 1; render(); }
    if (menos !== null) {
      CARRITO[+menos].cant = (CARRITO[+menos].cant || 1) - 1;
      if (CARRITO[+menos].cant <= 0) CARRITO.splice(+menos, 1);
      render();
    }
  });

  document.getElementById("carrito-boton").addEventListener("click", function () {
    panel.classList.toggle("abierto");
  });

  pagoBtn.addEventListener("click", function () { mediosEl.style.display = "block"; });

  mediosEl.addEventListener("click", function (e) {
    var m = e.target.closest(".medio");
    if (!m) return;
    medioSel = m.getAttribute("data-medio");
    var all = mediosEl.querySelectorAll(".medio");
    for (var i = 0; i < all.length; i++) all[i].classList.remove("seleccionado");
    m.classList.add("seleccionado");
    confirmarBtn.style.display = "block";
    okEl.style.display = "none";
  });

  function enviarWhatsApp() {
    var cliente = (window.MarketAttack && window.MarketAttack.CLIENTE) || {};
    var wa = cliente.whatsapp || "";
    var waLimp = wa.replace(/[^\d]/g, "");
    if (waLimp.length === 10 && waLimp.startsWith("3")) waLimp = "57" + waLimp;
    var body = "*PEDIDO MARKETATTACK*\n\n";
    body += CARRITO.map(function (i) { return "• " + i.cant + "x " + i.nombre + " — " + moneda(parsePrecio(i.precio) * (i.cant||1)); }).join("\n");
    body += "\n\n*Total:* " + moneda(total());
    body += "\n*Pago:* " + medioSel;
    var url = "https://wa.me/" + waLimp + "?text=" + encodeURIComponent(body);
    window.open(url, "_blank");
  }

  confirmarBtn.addEventListener("click", function () {
    if (!medioSel) {
      okEl.textContent = "❗ Primero elige un método de pago arriba.";
      okEl.style.display = "block";
      okEl.style.borderColor = "#e63946";
      okEl.style.background = "#fdecea";
      okEl.style.color = "#8a1a20";
      return;
    }
    okEl.style.borderColor = "#27ae60";
    okEl.style.background = "#eafaf1";
    okEl.style.color = "#145a2b";
    okEl.textContent = "✅ ¡Pedido confirmado por " + medioSel + " por " + moneda(total()) + "! Redirigiendo a WhatsApp...";
    okEl.style.display = "block";
    try {
      var MC = window.MarketAttack;
      if (MC && MC.guardarListaProspectos) {
        var lista = (MC.leerProspectos ? MC.leerProspectos() : []);
        lista.push({
          id: Date.now() + "-" + Math.floor(Math.random() * 999),
          nombre: "Cliente (pedido web)",
          telefono: "—",
          interes: "Pedido " + moneda(total()) + " · " + medioSel + " · " + CARRITO.map(function (i) { return i.cant + "x " + i.nombre; }).join(", "),
          estado: "nuevo",
          fecha: new Date().toLocaleString("es-CO")
        });
        MC.guardarListaProspectos(lista);
      }
    } catch (e) {}
    setTimeout(enviarWhatsApp, 500);
    CARRITO = [];
    render();
  });

  root.addEventListener("click", function (e) {
    var rb = e.target.closest(".red-btna");
    if (rb) { window.open(rb.getAttribute("data-red"), "_blank"); }
  });

  window.MarketAttackCarrito = {
    agregar: function (nombre, precio) {
      var ex = null;
      for (var i = 0; i < CARRITO.length; i++) { if (CARRITO[i].nombre === nombre) { ex = CARRITO[i]; break; } }
      if (ex) { ex.cant = (ex.cant || 1) + 1; }
      else { CARRITO.push({ nombre: nombre, precio: precio, cant: 1 }); }
      render();
    }
  };

  function enlazarMenu() {
    var items = document.querySelectorAll(".producto, .menu-item, .tarjeta-producto, [data-producto], [class*=\"produc\"], .card");
    if (!items.length) return;
    for (var i = 0; i < items.length; i++) {
      var el = items[i];
      if (el.getAttribute("data-carro") === "1") continue;
      var texto = (el.textContent || "").replace(/\s+/g, " ").trim();
      var pc = (texto.match(/\$\s?[0-9][0-9.,]*/) || [])[0];
      if (!pc) continue;
      var nombre = (el.getAttribute("data-nombre") || el.querySelector("h3,h4,.nombre,.titulo") && el.querySelector("h3,h4,.nombre,.titulo").textContent || texto.split("$")[0]).trim();
      if (!nombre) continue;
      el.setAttribute("data-carro", "1");
      var btn = document.createElement("button");
      btn.textContent = "🛒 Agregar";
      btn.style.cssText = "margin-left:8px;background:#e63946;color:#fff;border:none;border-radius:8px;padding:4px 10px;font-size:12px;cursor:pointer";
      btn.onclick = function (nombre_, precio_) { return function (ev) { ev.preventDefault(); ev.stopPropagation(); window.MarketAttackCarrito.agregar(nombre_, precio_); }; }(nombre, pc);
      el.appendChild(btn);
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", function () {
      enlazarMenu();
      setInterval(function () { if (!panel.classList.contains("mas")) enlazarMenu(); }, 1500);
    });
  } else {
    enlazarMenu();
    setInterval(function () { enlazarMenu(); }, 1500);
  }

  console.log("[carrito] módulo listo ✔");
})();
