ARG NPM_DOMAIN

FROM alpine:latest

RUN apk add --no-cache wget bash libc6-compat file jq

RUN wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 \
    -O /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared && \
    cloudflared tunnel login && \
    cloudflared tunnel create npm

COPY config.yml /root/config.yml

RUN TUNNEL_ID=$(cloudflared tunnel list --output json | jq -r '.[] | select(.name=="npm") | .id') && \
    sed -i "s/__NPM_KEY__/$TUNNEL_ID/g" /root/config.yml

RUN cloudflared tunnel route dns npm ${NPM_DOMAIN}

ENTRYPOINT ["sh", "-c", "cloudflared tunnel --config /root/config.yml run --url http://${NPM_IP}:${NPM_PORT}"]