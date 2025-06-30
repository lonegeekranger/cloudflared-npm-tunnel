#!/bin/bash

if [ -z "$NPM_DOMAIN" ] || [ -z "$NPM_IP" ] || [ -z "$NPM_PORT" ]; then
    echo "❌ missing environment variables NPM_DOMAIN, NPM_IP y NPM_PORT... Leaving!!!"
    exit 1
fi

if [[ "$WIPE" == "true" ]]; then
    rm -rf .cloudflared
    rm -rf config.yml
    rm -rf .initialized
    rm -rf cloudflared
fi

if [ ! -f /home/app/config.yml ]; then
    echo -e "tunnel: npm\ncredentials-file: /home/app/.cloudflared/__NPM_KEY__.json" > /home/app/config.yml
fi


if [ ! -f /home/app/cloudflared ]; then
    wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O /home/app/cloudflared && \
    chmod +x /home/app/cloudflared
fi

if [ ! -f /home/app/.cloudflared/cert.pem ]; then
    /home/app/cloudflared tunnel login
fi

if [ ! -f /home/app/.initialized ]; then
    /home/app/cloudflared tunnel delete npm || echo "npm tunnel not found, this is good!" && \
    /home/app/cloudflared tunnel create npm && \
    TUNNEL_ID=$(/home/app/cloudflared tunnel list --output json | jq -r '.[] | select(.name=="npm") | .id') && \
    sed -i "s/__NPM_KEY__/$TUNNEL_ID/g" /home/app/config.yml && \
    /home/app/cloudflared tunnel route dns -f npm $NPM_DOMAIN && \
    touch /home/app/.initialized
fi

/home/app/cloudflared tunnel --config /home/app/config.yml run --url http://${NPM_IP}:${NPM_PORT}