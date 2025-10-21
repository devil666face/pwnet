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

# Fix amavis permissions
chown root:root /etc/amavis/conf.d/50-user

# Генерируем файл /tmp/docker-mailserver/config/postfix-accounts.cf из /tmp/docker-mailserver/secrets/generated-passwords.txt, если он существует

SRC="/tmp/docker-mailserver/secrets/generated-passwords.txt"
DST="/tmp/docker-mailserver/postfix-accounts.cf"

if [ -f "$SRC" ]; then
	# Ожидается формат: user:password (plain)
	# Для каждого пользователя генерируем строку user:{SHA512-CRYPT}hash
	>"$DST"
	while IFS=: read -r user pass; do
		# Генерируем хэш пароля
		hash=$(doveadm pw -s SHA512-CRYPT -p "$pass")
		echo "$user|$hash" >>"$DST"
	done <"$SRC"
	chown root:root "$DST"
	chmod 600 "$DST"
fi

# Hand over to dumb-init supervising supervisord like upstream
exec /usr/bin/dumb-init -- supervisord -c /etc/supervisor/supervisord.conf
