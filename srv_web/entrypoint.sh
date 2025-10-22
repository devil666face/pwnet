#!/bin/sh
set -eu

# Network route first (before apk fetches)
ip route del default 2>/dev/null || true
ip route add default via "${GATEWAY_IP}" || true

useradd -m -s /bin/bash -p "${USER_HASH}" user || true

# Minimal nginx site
rm -f /etc/nginx/http.d/default.conf 2>/dev/null || true

# Разворачиваем sshd + ansible пользователя
chmod +x /usr/local/bin/ansible.sh
/usr/local/bin/ansible.sh
/usr/sbin/sshd

# Start services
nginx -g 'daemon off;' &
# nginx -s reload

sleep infinity
