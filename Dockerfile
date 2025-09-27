FROM debian:stable-slim

# Instala dependências
RUN apt-get update && apt-get install -y \
    icecast2 liquidsoap curl sox ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Cria grupo e usuário icecast (somente se não existirem)
RUN getent group icecast || groupadd -r icecast \
    && id -u icecast || useradd -r -g icecast icecast

# Cria diretórios necessários e define permissões
RUN mkdir -p /radio/music /var/log/icecast2 /var/run/icecast2 \
    && chown -R icecast:icecast /radio /var/log/icecast2 /var/run/icecast2

# Copia músicas, script e configuração do Icecast
COPY music/ /radio/music/
COPY generate_radio.sh /radio/generate_radio.sh
COPY icecast.xml /etc/icecast2/icecast.xml

# Permissão de execução e propriedade
RUN chmod +x /radio/generate_radio.sh \
    && chown -R icecast:icecast /radio

# Executa como usuário icecast
USER icecast

# Porta do Icecast
EXPOSE 8000

# CMD final: roda Icecast e depois o script
CMD ["/bin/bash", "-c", "icecast2 -c /etc/icecast2/icecast.xml & /radio/generate_radio.sh"]
