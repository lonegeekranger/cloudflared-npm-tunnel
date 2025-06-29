#!/bin/bash

export HOME=/opt

if [ -z "$NPM_DOMAIN" ] || [ -z "$NPM_IP" ] || [ -z "$NPM_PORT" ]; then
    echo "❌ missing environment variables NPM_DOMAIN, NPM_IP y NPM_PORT... Leaving!!!"
    exit 1
fi

if [[ "$WIPE" == "true" ]]; then
    rm -rf /opt/.cloudflared
    rm -rf /opt/config.yml
    rm -rf /opt/.initialized
    rm -rf /opt/cloudflared
fi

if [ ! -f /opt/config.yml ]; then
    echo -e "tunnel: npm\ncredentials-file: /opt/.cloudflared/__NPM_KEY__.json" > /opt/config.yml
fi


if [ ! -f /opt/cloudflared ]; then
    wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O /opt/cloudflared && \
    chmod +x /opt/cloudflared
fi



if [ ! -f /opt/.cloudflared/cert.pem ]; then
    /opt/cloudflared tunnel login
fi

if [ ! -f /opt/.initialized ]; then
    /opt/cloudflared tunnel delete npm || echo "npm tunnel not found, this is good!" && \
    /opt/cloudflared tunnel create npm && \
    TUNNEL_ID=$(/opt/cloudflared tunnel list --output json | jq -r '.[] | select(.name=="npm") | .id') && \
    sed -i "s/__NPM_KEY__/$TUNNEL_ID/g" /opt/config.yml && \
    /opt/cloudflared tunnel route dns -f npm $NPM_DOMAIN && \
    touch /opt/.initialized
fi

/opt/cloudflared tunnel --config /opt/config.yml run --url http://${NPM_IP}:${NPM_PORT}