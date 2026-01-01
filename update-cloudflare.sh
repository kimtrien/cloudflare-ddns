#!/bin/bash
# Cloudflare DDNS Updater (Advanced Docker Version)
# Detect IP (LAN/public), retry on fail, log to stdout + file

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
source "$SCRIPT_DIR/cloudflare.env"

IP_FILE="/tmp/current_ip.txt"
LOG_FILE="/tmp/cloudflare-ddns.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $*" | tee -a "$LOG_FILE"
}

get_ip() {
    if [ "$IP_TYPE" = "public" ]; then
        curl -s --max-time 10 https://api.ipify.org
    else
        ip -4 addr show "$LAN_INTERFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n1
    fi
}

update_dns() {
    local new_ip=$1
    local retries=3
    local delay=5

    for ((i=1;i<=retries;i++)); do
        RESPONSE=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
            -H "Authorization: Bearer $CF_API_TOKEN" \
            -H "Content-Type: application/json" \
            --data "{\"type\":\"A\",\"name\":\"$DNS_NAME\",\"content\":\"$new_ip\",\"ttl\":$TTL,\"proxied\":$PROXIED}")
        
        if echo "$RESPONSE" | grep -q '"success":true'; then
            log "Updated Cloudflare DNS to $new_ip"
            echo "$new_ip" > "$IP_FILE"
            return 0
        else
            log "Attempt $i failed: $RESPONSE"
            sleep $delay
        fi
    done
    log "Failed to update Cloudflare DNS after $retries attempts"
}

while true; do
    CURRENT_IP=$(get_ip)
    if [ -z "$CURRENT_IP" ]; then
        log "No IP detected, retrying in $UPDATE_INTERVAL seconds"
        sleep "$UPDATE_INTERVAL"
        continue
    fi

    OLD_IP=$(cat "$IP_FILE" 2>/dev/null)

    if [ "$CURRENT_IP" != "$OLD_IP" ]; then
        log "IP changed from $OLD_IP to $CURRENT_IP"
        update_dns "$CURRENT_IP"
    else
        log "IP unchanged: $CURRENT_IP"
    fi

    sleep "$UPDATE_INTERVAL"
done
