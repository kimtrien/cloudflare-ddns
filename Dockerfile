# Base image nhẹ, có curl
FROM alpine:3.20

# Cài curl, bash
RUN apk add --no-cache bash curl

# Copy script và env
WORKDIR /app
COPY update-cloudflare.sh /app/update-cloudflare.sh
COPY cloudflare.env /app/cloudflare.env

# Make script executable
RUN chmod +x /app/update-cloudflare.sh

# Chạy script định kỳ: cron có thể dùng trong container
# Ở đây dùng entrypoint loop mỗi 5 phút
ENTRYPOINT ["/bin/bash", "-c", "while true; do /app/update-cloudflare.sh; sleep 300; done"]

