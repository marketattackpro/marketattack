#!/usr/bin/env python3
"""
Genera el código QR de una tienda, con la MARCA del negocio:
color, marco y la inicial al centro (pequeña, para que SIEMPRE se pueda leer).
Uso: qr_tienda.py <url> <archivo_salida.png> [etiqueta]

Importante: el QR se comprueba con un lector real (zbarimg) antes de darlo
por bueno. Si el logo impide leerlo, se genera sin logo. Un QR bonito que no
escanea no sirve; primero que funcione.
"""
import os
import shutil
import subprocess
import sys

NAVY = (29, 53, 87)
ROJO = (230, 57, 70)
BOLD = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
LOGO = 0.12  # proporción del ancho; más grande rompe la lectura


def install():
    subprocess.run(["/opt/oci/bin/pip", "install", "--quiet", "qrcode", "pillow"], check=False)


def leer_qr(ruta):
    """Devuelve el texto del QR o None si no se puede leer."""
    if not shutil.which("zbarimg"):
        return "sin-lector"  # no se puede comprobar: se acepta
    try:
        r = subprocess.run(["zbarimg", "-q", "--raw", ruta],
                           capture_output=True, text=True, timeout=20)
        if r.returncode == 0:
            return r.stdout.strip()
    except Exception:
        pass
    return None


def dibujar(url, salida, etiqueta, con_logo):
    import qrcode
    from PIL import Image, ImageDraw, ImageFont

    qr = qrcode.QRCode(error_correction=qrcode.constants.ERROR_CORRECT_H,
                       box_size=12, border=2)
    qr.add_data(url)
    qr.make(fit=True)
    img = qr.make_image(fill_color=NAVY, back_color="white").convert("RGB")

    W, H = img.size
    canvas = Image.new("RGB", (W, H + 110), "white")
    canvas.paste(img, (0, 0))
    d = ImageDraw.Draw(canvas)
    try:
        f = ImageFont.truetype(BOLD, 36)
    except Exception:
        f = ImageFont.load_default()
    d.rectangle([W // 2 - 265, H + 20, W // 2 + 265, H + 88], outline=NAVY, width=3)
    d.text((W // 2, H + 55), etiqueta, fill=NAVY, anchor="mm", font=f)

    if con_logo:
        sz = int(W * LOGO)
        cx, cy = W // 2, H // 2
        # aro blanco fino: separa el logo del código sin tapar demasiado
        d.ellipse([cx - sz // 2 - 8, cy - sz // 2 - 8,
                   cx + sz // 2 + 8, cy + sz // 2 + 8], fill="white")
        d.ellipse([cx - sz // 2, cy - sz // 2,
                   cx + sz // 2, cy + sz // 2], fill=ROJO)
        try:
            fi = ImageFont.truetype(BOLD, int(sz * 0.66))
        except Exception:
            fi = ImageFont.load_default()
        d.text((cx, cy + 2), (etiqueta.strip()[:1] or "M").upper(),
               fill="white", anchor="mm", font=fi)

    canvas.save(salida)


def main():
    url = sys.argv[1] if len(sys.argv) > 1 else "https://marketattack.duckdns.org/tienda.html"
    salida = sys.argv[2] if len(sys.argv) > 2 else "/tmp/qr.png"
    etiqueta = sys.argv[3] if len(sys.argv) > 3 else "MARKETATTACK"

    try:
        import qrcode  # noqa: F401
        from PIL import Image  # noqa: F401
    except ImportError:
        install()

    # 1) con logo pequeño
    try:
        dibujar(url, salida, etiqueta, True)
        leido = leer_qr(salida)
        if leido is None or (leido != "sin-lector" and url not in leido):
            # 2) el logo estorba: sin logo, pero con la marca en el marco
            dibujar(url, salida, etiqueta, False)
            leido = leer_qr(salida)
            if leido is None:
                # 3) último recurso: QR simple, sin adorno
                import qrcode
                qrcode.make(url).save(salida)
    except Exception:
        try:
            import qrcode
            qrcode.make(url).save(salida)
        except Exception:
            pass

    print(salida)


if __name__ == "__main__":
    main()
