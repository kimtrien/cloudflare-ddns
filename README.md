# Cloudflare DDNS Updater

Script tự động cập nhật IP public lên Cloudflare A record.

## Cài đặt

1. Copy `cloudflare.env.example` → `cloudflare.env` và điền token/zone/record thật.
2. Copy `update-cloudflare.sh` → `/usr/local/bin/` và chmod +x.
3. Cài systemd service:

```
sudo cp systemd/cloudflare-ddns.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable cloudflare-ddns
sudo systemctl start cloudflare-ddns
```

4. Tùy chọn: chạy cron hoặc dispatcher để cập nhật liên tục.

## Docker cách dùng

1. Copy `cloudflare.env.example` → `cloudflare.env` và điền token/zone/record.

2. Build image:

```
docker-compose build
```

3. Chạy container:

```
docker-compose up -d
```

4. Kiểm tra log:

```
docker logs -f cloudflare-ddns
```

Container sẽ chạy liên tục, check IP mỗi 5 phút và update Cloudflare khi cần.


## Cấu trúc thư mục

```
cloudflare-ddns/
├── update-cloudflare.sh        # Script chính
├── cloudflare.env.example      # File mẫu lưu token, zone, record
├── systemd/
│   └── cloudflare-ddns.service # Systemd service
├── dispatcher/
│   └── 90-cloudflare-ddns      # NM dispatcher (tuỳ chọn)
├── cron/
│   └── cloudflare-ddns.cron    # Cron job (tuỳ chọn)
└── README.md                   # Hướng dẫn sử dụng
```

## License

MIT
