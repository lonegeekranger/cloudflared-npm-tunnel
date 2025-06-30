FROM alpine:latest

RUN apk add --no-cache wget bash libc6-compat file jq \
    && adduser -D app

COPY run.sh /home/app/run.sh
RUN chmod +x /home/app/run.sh
RUN chown app:app /home/app/run.sh

USER app

ENTRYPOINT ["/home/app/run.sh"]