#!/bin/bash
# Cloudflare DDNS Updater (Docker version)
# Lấy IP public, update Cloudflare nếu thay đổi

# Load env
source /app/cloudflare.env

IP_FILE="/tmp/current_ip.txt"

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

