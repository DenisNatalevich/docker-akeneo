#! /bin/bash

set -e

# Check install
if [ ! -f /var/www/html/.docker-installed ]; then
	if [ "${1:0:3}" = 'php' ]; then
		# php image
		/opt/install-akeneo.sh
	else
		# queue image
		echo >&2 'error: akeneo not ready, start me later'
		exit 1
	fi
fi


# Force perms
test -d /var/www/html/var && chown -R www-data /var/www/html/var

exec "$@"