#!/usr/bin/env bash
set -uo pipefail

# ---- HARDCODED (koi env variable nahi) ----
SSH_USER="vps"
SSH_PASSWORD="vps12345"
CHISEL_USER="tunnel"
CHISEL_PASS="tunnel12345"
# -------------------------------------------

# make sure password is set at runtime too
echo "$SSH_USER:$SSH_PASSWORD" | chpasswd

# start sshd
/usr/sbin/sshd -p 22
echo "[+] sshd running on :22  user=$SSH_USER  pass=$SSH_PASSWORD"

# chisel server (bridges WebSocket -> TCP 22)
chisel server --host 127.0.0.1 --port 8080 --auth "$CHISEL_USER:$CHISEL_PASS" >/tmp/chisel.log 2>&1 &
echo "[+] chisel server on 127.0.0.1:8080"

# cloudflare quick tunnel -> chisel
cloudflared tunnel --url http://localhost:8080 --no-autoupdate >/tmp/cf.log 2>&1 &
echo "[+] cloudflare tunnel starting..."

# grab generated domain
DOMAIN=""
for i in $(seq 1 30); do
  DOMAIN=$(grep -oE 'https://[a-z0-9-]+\.trycloudflare\.com' /tmp/cf.log 2>/dev/null | head -1)
  [ -n "$DOMAIN" ] && break
  sleep 2
done

echo "=================================================="
if [ -n "$DOMAIN" ]; then
  echo " DOMAIN: $DOMAIN"
  echo " SSH USER: $SSH_USER   PASS: $SSH_PASSWORD"
  echo "--------------------------------------------------"
  echo " On your PC:"
  echo "   chisel client --auth $CHISEL_USER:$CHISEL_PASS $DOMAIN 2223:localhost:22"
  echo "   ssh -p 2223 $SSH_USER@127.0.0.1"
else
  echo " [!] domain not detected; check /tmp/cf.log"
fi
echo "=================================================="

# keep container alive
tail -f /dev/null
