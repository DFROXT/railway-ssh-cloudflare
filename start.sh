#!/usr/bin/env bash
set -uo pipefail

SSH_USER="root"
SSH_PASSWORD="dev"

echo "$SSH_USER:$SSH_PASSWORD" | chpasswd
/usr/sbin/sshd -p 22
echo "[+] sshd on :22  user=$SSH_USER  pass=$SSH_PASSWORD"

ngrok tcp 22 --log=stdout >/tmp/ngrok.log 2>&1 &
echo "[+] ngrok starting..."

URL=""
for i in $(seq 1 25); do
  URL=$(grep -oE 'tcp://[a-z0-9.-]+:[0-9]+' /tmp/ngrok.log 2>/dev/null | head -1)
  [ -n "$URL" ] && break
  sleep 2
done

echo "=================================================="
if [ -n "$URL" ]; then
  HOST=$(echo "$URL" | sed -E 's#^tcp://##; s#:[0-9]+$##')
  PORT=$(echo "$URL" | sed -E 's#.*:##')
  echo " SSH : ssh -p $PORT $SSH_USER@$HOST"
  echo " USER: $SSH_USER   PASS: $SSH_PASSWORD"
else
  echo " [!] ngrok url not found; check /tmp/ngrok.log"
fi
echo "=================================================="

tail -f /dev/null
