#!/usr/bin/env python3
"""
MARKETATTACK · Reconstruye la tienda autocontenida (un solo archivo)
Toma 02_DEMO/tienda.html + assets/{style.css,demo.js,carrito.js} y los
inserta dentro para generar assets/tienda_autocontenida.html.
Uso:  python3 scripts/build_standalone.py
"""
import base64, os

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEMO = os.path.join(BASE, "02_DEMO")
ASSETS = os.path.join(DEMO, "assets")


def leer(ruta):
    with open(ruta, encoding="utf-8") as f:
        return f.read()


def data_uri(ruta):
    with open(ruta, "rb") as f:
        return "data:image/png;base64," + base64.b64encode(f.read()).decode()


def main():
    html = leer(os.path.join(DEMO, "tienda.html"))
    css = leer(os.path.join(ASSETS, "style.css"))
    demo = leer(os.path.join(ASSETS, "demo.js"))
    carrito = leer(os.path.join(ASSETS, "carrito.js"))

    html = html.replace('<link rel="stylesheet" href="assets/style.css">',
                        "<style>\n" + css + "\n</style>")
    html = html.replace('<script src="assets/demo.js"></script>',
                        "<script>\n" + demo + "\n</script>")
    html = html.replace('<script src="assets/carrito.js"></script>',
                        "<script>\n" + carrito + "\n</script>")
    # el ícono se incrusta para que el archivo funcione aunque se mueva de carpeta
    fav = os.path.join(ASSETS, "favicon.png")
    if os.path.exists(fav):
        html = html.replace('href="assets/favicon.png"', 'href="' + data_uri(fav) + '"')

    salida = os.path.join(ASSETS, "tienda_autocontenida.html")
    with open(salida, "w", encoding="utf-8") as f:
        f.write(html)
    print("OK ->", salida, "(", len(html), "bytes )")


if __name__ == "__main__":
    main()
