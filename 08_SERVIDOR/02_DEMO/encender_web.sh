#!/usr/bin/env bash
pkill -f "http.server 8000" 2>/dev/null; sleep 1
nohup python3 -m http.server 8000 --directory "$(dirname "$0")" >/tmp/web8000.log 2>&1 &
sleep 2
echo "Web encendida -> http://localhost:8000/tienda.html"
