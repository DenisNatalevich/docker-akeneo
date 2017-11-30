#! /bin/bash

set -e

# Check install
if [ ! -f /var/www/html/.docker-installed ]; then
	bash /opt/install-akeneo.sh
fi

# Force perms
test -d /var/www/html/var && chown -R www-data /var/www/html/var

exec "$@"