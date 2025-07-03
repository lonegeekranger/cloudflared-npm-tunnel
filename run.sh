#!/bin/bash

HOME=/home/app/data
ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
    URL="cloudflared-linux-amd64"
elif [ "$ARCH" = "aarch64" ]; then
    URL="cloudflared-linux-arm64"
elif [ "$ARCH" = "arm64" ]; then
    URL="cloudflared-linux-arm64"
else
    echo "❌ Not supported: $ARCH"
    exit 1
fi

if [ -z "$NPM_DOMAIN" ] || [ -z "$NPM_IP" ] || [ -z "$NPM_PORT" ]; then
    echo "❌ missing environment variables NPM_DOMAIN, NPM_IP y NPM_PORT... Leaving!!!"
    exit 1
fi

if [[ "$WIPE" == "true" ]]; then
    rm -rf $HOME/.cloudflared
    rm -rf $HOME/config.yml
    rm -rf $HOME/.initialized
    rm -rf $HOME/cloudflared
fi

if [ ! -f $HOME/config.yml ]; then
    echo -e "tunnel: npm\ncredentials-file: $HOME/.cloudflared/__NPM_KEY__.json" > $HOME/config.yml
fi


if [ ! -f $HOME/cloudflared ]; then
    wget "https://github.com/cloudflare/cloudflared/releases/latest/download/${URL}" -O $HOME/cloudflared && \
    chmod +x $HOME/cloudflared
fi

if [ ! -f $HOME/.cloudflared/cert.pem ]; then
    $HOME/cloudflared tunnel login
fi

if [ ! -f $HOME/.initialized ]; then
    $HOME/cloudflared tunnel delete npm || echo "npm tunnel not found, this is good!" && \
    $HOME/cloudflared tunnel create npm && \
    TUNNEL_ID=$($HOME/cloudflared tunnel list --output json | jq -r '.[] | select(.name=="npm") | .id') && \
    sed -i "s/__NPM_KEY__/$TUNNEL_ID/g" $HOME/config.yml && \
    $HOME/cloudflared tunnel route dns -f npm $NPM_DOMAIN && \
    touch $HOME/.initialized
fi

$HOME/cloudflared tunnel --config $HOME/config.yml run --url http://${NPM_IP}:${NPM_PORT}