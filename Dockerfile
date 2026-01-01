FROM alpine:3.20

RUN apk add --no-cache bash curl iproute2

WORKDIR /app
COPY update-cloudflare.sh /app/update-cloudflare.sh
COPY cloudflare.env /app/cloudflare.env

RUN chmod +x /app/update-cloudflare.sh

ENTRYPOINT ["/bin/bash", "/app/update-cloudflare.sh"]
