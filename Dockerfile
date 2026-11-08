FROM debian:12-slim
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server curl ca-certificates gnupg sudo \
    && rm -rf /var/lib/apt/lists/*

# ngrok via official apt repo
RUN curl -fsSL --retry 5 --retry-delay 3 https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
      | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
    && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" > /etc/apt/sources.list.d/ngrok.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends ngrok \
    && rm -rf /var/lib/apt/lists/*

# ngrok authtoken (hardcoded)
RUN ngrok config add-authtoken 2qemlkWYtoHWjZJNT5cjdmJXH3n_6diF7ZQq3Uietkua8M1d

# ---- HARDCODED LOGIN ----
RUN echo 'root:dev' | chpasswd

RUN sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/^#\?UsePAM.*/UsePAM yes/' /etc/ssh/sshd_config \
    && mkdir -p /run/sshd

EXPOSE 22
COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]
