#!/usr/bin/env python3
"""
Genera el código QR de una tienda, con la MARCA del negocio:
color, marco y la inicial al centro. Listo para compartir por WhatsApp.
Uso: qr_tienda.py <url> <archivo_salida.png> [etiqueta]
"""
import os
import sys

NAVY = (29, 53, 87)
ROJO = (230, 57, 70)
BOLD = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"


def install():
    import subprocess
    subprocess.run(["/opt/oci/bin/pip", "install", "--quiet", "qrcode", "pillow"], check=False)


def main():
    url = sys.argv[1] if len(sys.argv) > 1 else "https://157-137-203-223.sslip.io/tienda.html"
    salida = sys.argv[2] if len(sys.argv) > 2 else "/tmp/qr.png"
    etiqueta = sys.argv[3] if len(sys.argv) > 3 else "MARKETATTACK"
    try:
        import qrcode
    except ImportError:
        install()
        import qrcode

    try:
        from PIL import Image, ImageDraw, ImageFont
    except Exception:
        Image = None

    try:
        if Image is not None:
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
            # inicial de la marca al centro del QR
            sz = int(W * 0.22)
            cx, cy = W // 2, H // 2
            d.ellipse([cx - sz // 2 - 12, cy - sz // 2 - 12, cx + sz // 2 + 12, cy + sz // 2 + 12], fill="white")
            d.ellipse([cx - sz // 2, cy - sz // 2, cx + sz // 2, cy + sz // 2], fill=ROJO)
            try:
                fi = ImageFont.truetype(BOLD, int(sz * 0.66))
            except Exception:
                fi = ImageFont.load_default()
            d.text((cx, cy + 2), (etiqueta.strip()[:1] or "M").upper(),
                   fill="white", anchor="mm", font=fi)
            canvas.save(salida)
        else:
            qrcode.make(url).save(salida)
    except Exception:
        # ante cualquier problema, un QR simple (nunca falla)
        try:
            qrcode.make(url).save(salida)
        except Exception:
            pass
    print(salida)


if __name__ == "__main__":
    main()
