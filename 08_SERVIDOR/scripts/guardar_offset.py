import subprocess, json, urllib.request, os

tok = subprocess.run("sudo grep TELEGRAM_TOKEN /etc/marketattack/telegram.conf",
                     shell=True, capture_output=True, text=True).stdout
tok = tok.split("=", 1)[1].strip().strip('"')

RUTA = "/home/ubuntu/.marketattack_offset"
try:
    off = int(open(RUTA).read().strip())
except Exception:
    off = 0
print("  offset actual:", off)

url = f"https://api.telegram.org/bot{tok}/getUpdates?offset={off}&timeout=3"
d = json.loads(urllib.request.urlopen(url, timeout=25).read())
res = d.get("result", [])
if res:
    nuevo = max(u["update_id"] for u in res) + 1
    subprocess.run(f"echo {nuevo} | sudo tee {RUTA} >/dev/null && sudo chmod 600 {RUTA}",
                   shell=True)
    print(f"  cola tenía {len(res)} update(s) -> anclado en offset={nuevo}")
else:
    print("  cola vacía: Telegram no tiene updates pendientes")
    print(f"  se deja offset={off} (quedará protegido en cuanto llegue un mensaje real)")
