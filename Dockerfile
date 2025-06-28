FROM alpine:latest

# Instala dependencias necesarias
RUN apk add --no-cache wget bash libc6-compat file

# Descarga cloudflared para ARM64 y lo instala
RUN wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 \
    -O /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared