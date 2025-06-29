FROM alpine:latest

RUN apk add --no-cache wget bash libc6-compat file jq

COPY run.sh /root/run.sh
RUN chmod +x /root/run.sh

ENTRYPOINT ["/root/run.sh"]