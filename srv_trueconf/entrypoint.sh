#!/usr/bin/env bash
set -euo pipefail

# Network route first (before apk fetches)
ip route del default 2>/dev/null || true
ip route add default via "$GATEWAY_IP" || true

# Prepare ansible user and sshd configuration
chmod +x /usr/local/bin/ansible.sh
/usr/local/bin/ansible.sh

# Launch SSH daemon for ansible access
/usr/sbin/sshd -D -e &

/root/entrypoint.sh
