FROM debian:stable-slim

# ==============================
# Instala dependências
# ==============================
RUN apt-get update && apt-get install -y \
    icecast2 \
    liquidsoap \
    curl \
    sox \
    ffmpeg \
    python3 \
    python3-pip \
    bash \
    && rm -rf /var/lib/apt/lists/*

# ==============================
# Cria grupo e usuário icecast
# ==============================
RUN getent group icecast || groupadd -r icecast \
    && id -u icecast || useradd -r -g icecast -m icecast

# ==============================
# Cria diretórios necessários
# ==============================
RUN mkdir -p /radio/music /radio/scripts /var/log/icecast2 /var/run/icecast2 \
    && chown -R icecast:icecast /radio /var/log/icecast2 /var/run/icecast2

# ==============================
# Copia músicas, script Python e configuração do Icecast
# ==============================
COPY music/ /radio/music/
COPY generate_radio.py /radio/scripts/generate_radio.py
COPY icecast.xml /etc/icecast2/icecast.xml

# Permissões
RUN chmod +x /radio/scripts/generate_radio.py \
    && chown -R icecast:icecast /radio

# ==============================
# Usuário não root
# ==============================
USER icecast

# ==============================
# Porta do Icecast
# ==============================
EXPOSE 8000

# ==============================
# CMD final: roda Icecast e depois o script Python
# ==============================
CMD ["bash", "-c", "icecast2 -c /etc/icecast2/icecast.xml & python3 /radio/scripts/generate_radio.py"]
