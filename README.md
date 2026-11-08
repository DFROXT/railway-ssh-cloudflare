# railway-ssh-vps (ngrok)

Railway VPS with SSH login via an **ngrok TCP tunnel**. No env variables — everything is hardcoded in the image.

## Deploy
1. Railway → New Project → Deploy from GitHub → pick this repo.
2. Deploy. Done.

## Login (hardcoded)
- user: `root` / pass: `dev`

## After deploy — read Railway logs
Logs print something like:

```
==================================================
 SSH : ssh -p 12345 root@0.tcp.ngrok.io
 USER: root   PASS: dev
==================================================
```

Then run exactly that command from your machine:

```
ssh -p <PORT> root@<HOST>
```

Enter password `dev`.

> Note: ngrok free URL changes on every restart/redeploy. Re-read the logs after each deploy.
