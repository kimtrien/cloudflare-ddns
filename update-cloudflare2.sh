#!/bin/bash
# Cloudflare DDNS Updater
# Chạy trên Ubuntu 22.04+, Docker/Nginx safe

# Load environment variables
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
if [ -f "$SCRIPT_DIR/cloudflare.env" ]; then
    source "$SCRIPT_DIR/cloudflare.env"
else
    echo "ERROR: cloudflare.env not found"
    exit 1
fi

IP_FILE="/tmp/current_ip.txt"

# Lấy IP public
IP=$(curl -s https://api.ipify.org)

OLD_IP=$(cat $IP_FILE 2>/dev/null)

if [ "$IP" != "$OLD_IP" ]; then
    echo "$(date): Updating Cloudflare IP from $OLD_IP to $IP"

    RESPONSE=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
      -H "Authorization: Bearer $CF_API_TOKEN" \
      -H "Content-Type: application/json" \
      --data "{\"type\":\"A\",\"name\":\"$DNS_NAME\",\"content\":\"$IP\",\"ttl\":120,\"proxied\":false}")

    echo $IP > $IP_FILE
    echo "$(date): Response: $RESPONSE"
else
    echo "$(date): IP unchanged: $IP"
fi

