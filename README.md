# railway-ssh-vps

Railway VPS with SSH login. No environment variables — everything is hardcoded.

## Deploy
1. Railway -> New Project -> Deploy from GitHub -> select this repo.
2. Deploy. That's it.

## Login (fixed in repo)
- user: `vps`
- pass: `vps12345`
- root: `root12345`

## After deploy
Railway logs me ye aayega:

```
 DOMAIN: https://xxxx.trycloudflare.com
 SSH USER: vps   PASS: vps12345
```

## Connect from your PC
```
chisel client --auth tunnel:tunnel12345 https://xxxx.trycloudflare.com 2223:localhost:22
ssh -p 2223 vps@127.0.0.1
```

## Change login
`Dockerfile` me ye line edit karo:
```
RUN useradd -m -s /bin/bash vps \
    && echo 'vps:vps12345' | chpasswd \
    && echo 'root:root12345' | chpasswd
```
Aur `start.sh` me `SSH_USER` / `SSH_PASSWORD` / `CHISEL_USER` / `CHISEL_PASS` values badal do.
