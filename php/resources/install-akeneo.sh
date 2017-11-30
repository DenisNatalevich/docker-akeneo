#! /bin/bash

set -e

# Functions
sed_escape() {
	echo "'$@'" | sed 's/[\/&]/\\&/g'
}

set_config() {
	key="$1"
	value="$2"
	regex="^(\s*)$key\s*:"
	sed -ri "s/($regex\s*).*/\1$(sed_escape "$value")/" "app/config/$3"
}

# Checks
if [ -z "$MYSQL_DATABASE" -o -z "$MYSQL_USER" -o -z "$MYSQL_PASSWORD" ]; then
	echo >&2 'error: missing MYSQL_* environment variables'
	exit 1
fi

# Liens conteneurs
: ${MYSQL_LINK:=mysql}
: ${INDEXER_LINK:=indexer}

# Install
echo 'Download akeneo ...'
: ${AKENEO_URL:="https://download.akeneo.com/pim-community-standard-v2.0-latest.tar.gz"}
curl -sSL "$AKENEO_URL" | tar xzf - --directory /var/www/html --strip-components 1 --exclude='var/cache/*'

cd /var/www/html

composer config github-oauth.github.com "$GITHUB_TOKEN"
composer install --optimize-autoloader --prefer-dist
composer config --unset github-oauth.github.com

# Config
echo 'Config akeneo ...'
set_config database_host "$MYSQL_LINK" parameters.yml
set_config database_name "$MYSQL_DATABASE" parameters.yml
set_config database_user "$MYSQL_USER" parameters.yml
set_config database_password "$MYSQL_PASSWORD" parameters.yml
set_config secret $(head -c1M /dev/urandom | sha1sum | cut -d' ' -f1) parameters.yml
set_config index_hosts "$INDEXER_LINK: 9200" parameters.yml
cat app/config/parameters.yml

# Attente MySQL
TERM=dumb php -- "$MYSQL_LINK" "$MYSQL_USER" "$MYSQL_PASSWORD" <<'EOPHP'
<?php
$stderr = fopen('php://stderr', 'w');
$maxTries = 10;
do {
	$mysql = new mysqli($argv[1], $argv[2], $argv[3]);
	if ($mysql->connect_error) {
		fwrite($stderr, "\n" . 'MySQL Connection Error: (' . $mysql->connect_errno . ') ' . $mysql->connect_error . "\n");
		--$maxTries;
		if ($maxTries <= 0) {
			exit(1);
		}
		sleep(15);
	}
} while ($mysql->connect_error);
EOPHP
echo 'MySQL OK ...'

# Build
yarn install
php bin/console cache:clear --no-warmup --env=prod
php bin/console pim:installer:assets --symlink --clean --env=prod
bin/console pim:install --force --symlink --clean --env=prod
yarn run webpack

# Clean
composer clear-cache
yarn cache clean

# Install mark
date -R > .docker-installed