#!/usr/bin/env python3
"""
╔═══════════════════════════════════════════════════════════╗
║  MARKETATTACK · Menú imprimible (PNG + PDF)               ║
║  Genera una "carta" con la marca del negocio, lista para   ║
║  imprimir o enviar por WhatsApp. Sin internet.             ║
╚═══════════════════════════════════════════════════════════╝
Uso:
  menu_tienda.py --nombre "Panadería X" --salida menu.png [--pdf menu.pdf] \
     --whatsapp 3001234567 --horario "..." --ubicacion "..." --tagline "..." \
     --item "Pan campesino|4000|Recién horneado" --item "Café|2500|Tinto o con leche"
"""
import argparse, os

from PIL import Image, ImageDraw, ImageFont

AZUL = (29, 53, 87)
ROJO = (230, 57, 70)
CLARO = (168, 218, 220)
BLANCO = (245, 247, 250)
GRIS = (110, 120, 135)
NEGRO = (33, 37, 43)

BOLD = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
NORMAL = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"


def F(ruta, tam):
    try:
        return ImageFont.truetype(ruta, tam)
    except Exception:
        return ImageFont.load_default()


def envolver(d, texto, font, ancho):
    out, act = [], ""
    for p in str(texto).split():
        prueba = (act + " " + p).strip()
        if d.textlength(prueba, font=font) <= ancho or not act:
            act = prueba
        else:
            out.append(act); act = p
    if act:
        out.append(act)
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--nombre", required=True)
    ap.add_argument("--salida", required=True)
    ap.add_argument("--pdf", default="")
    ap.add_argument("--whatsapp", default="")
    ap.add_argument("--horario", default="")
    ap.add_argument("--ubicacion", default="")
    ap.add_argument("--tagline", default="")
    ap.add_argument("--item", action="append", default=[])
    a = ap.parse_args()

    W = 900
    margen = 60
    ancho_util = W - margen * 2

    items = []
    for it in a.item:
        p = [x.strip() for x in it.split("|")]
        while len(p) < 3:
            p.append("")
        items.append({"n": p[0], "precio": p[1], "desc": p[2]})
    if not items:
        items = [{"n": "Producto", "precio": "", "desc": ""}]

    # alto dinámico
    H = 210 + len(items) * 92 + 200
    img = Image.new("RGB", (W, H), BLANCO)
    d = ImageDraw.Draw(img)

    # cabecera
    d.rectangle([0, 0, W, 170], fill=AZUL)
    d.rectangle([0, 0, W, 12], fill=ROJO)
    d.text((margen, 46), a.nombre, font=F(BOLD, 46), fill=BLANCO)
    if a.tagline:
        d.text((margen, 112), a.tagline[:70], font=F(NORMAL, 26), fill=CLARO)
    d.text((W - margen - 150, 52), "MENÚ", font=F(BOLD, 34), fill=CLARO)

    # items
    y = 210
    for it in items:
        d.text((margen, y), it["n"], font=F(BOLD, 34), fill=NEGRO)
        if it["precio"]:
            pw = d.textlength(it["precio"], font=F(BOLD, 34))
            d.text((W - margen - pw, y), it["precio"], font=F(BOLD, 34), fill=ROJO)
        if it["desc"]:
            d.text((margen, y + 44), it["desc"][:80], font=F(NORMAL, 22), fill=GRIS)
        y += 92
        d.line([margen, y - 18, W - margen, y - 18], fill=(228, 231, 236))

    # pie
    y = H - 160
    d.rectangle([0, y, W, H], fill=AZUL)
    d.text((margen, y + 26), "Pide por WhatsApp", font=F(BOLD, 30), fill=BLANCO)
    linea = a.whatsapp or ""
    if a.horario:
        linea = (linea + "  ·  " + a.horario) if linea else a.horario
    if linea:
        d.text((margen, y + 70), linea[:70], font=F(NORMAL, 24), fill=CLARO)
    if a.ubicacion:
        d.text((margen, y + 104), a.ubicacion[:70], font=F(NORMAL, 22), fill=CLARO)
    d.text((W - margen - 230, y + 30), "MARKETATTACK", font=F(NORMAL, 20), fill=CLARO)

    os.makedirs(os.path.dirname(os.path.abspath(a.salida)), exist_ok=True)
    img.save(a.salida, "PNG", optimize=True)
    if a.pdf:
        img.save(a.pdf, "PDF", resolution=150.0)
    print(f"MENU_OK={a.salida}" + (f" PDF_OK={a.pdf}" if a.pdf else ""))


if __name__ == "__main__":
    main()
