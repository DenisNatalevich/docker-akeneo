#! /bin/bash

echo "Waiting for mysql ..."

# Liens conteneurs
: ${MYSQL_LINK:=mysql}
: ${INDEXER_LINK:=indexer}

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