# cloudflared-tunnels

## Build:

docker build -t cloudflared-npm-tunnel .

## Run:

docker run --rm -it -e NPM_IP=<IP> -e NPM_PORT=<PORT> -e NPM_DOMAIN=<npm.DOMAIN> -v cloudflared-npm-opt:/opt cloudflared-npm-tunnel