FROM debian:12-slim
ARG TARGETARCH=amd64
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server curl ca-certificates sudo \
    && rm -rf /var/lib/apt/lists/*

# chisel (WebSocket <-> TCP bridge)
RUN curl -fsSL --max-time 120 -o /tmp/chisel.gz "https://github.com/jpillora/chisel/releases/download/v1.12.0/chisel_1.12.0_linux_${TARGETARCH}.gz" \
    && gunzip -c /tmp/chisel.gz > /usr/local/bin/chisel \
    && chmod +x /usr/local/bin/chisel

# cloudflared
RUN curl -fsSL --max-time 120 -o /usr/local/bin/cloudflared "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${TARGETARCH}" \
    && chmod +x /usr/local/bin/cloudflared

# ---- HARDCODED LOGIN (change these lines if you want) ----
RUN useradd -m -s /bin/bash vps \
    && echo 'vps:vps12345' | chpasswd \
    && echo 'root:root12345' | chpasswd
# ----------------------------------------------------------

RUN sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/^#\?UsePAM.*/UsePAM yes/' /etc/ssh/sshd_config \
    && mkdir -p /run/sshd

EXPOSE 22
COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]
