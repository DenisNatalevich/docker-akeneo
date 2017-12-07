# akeneo

## Prérequis

* [Docker compose](https://docs.docker.com/compose/)
* Un [token Github](https://github.com/settings/tokens) pour composer (droit repo uniquement)

## Variables d'environnement

* MYSQL_LINK: host pour mysql (default: mysql)
* MYSQL_DATABASE: base de données pour akeneo
* MYSQL_USER: utilisateur mysql pour akeneo
* MYSQL_PASSWORD: mot de passe pour $MYSQL_USER
* INDEXER_LINK: host pour elasticsearch (default: indexer)
* GITHUB_TOKEN: Token github pour installation via composer

## Compose

### `docker-compose.yml`

	services:
	  data:
	    image: tianon/true
	    volumes:
	    - /var/www/html

	  indexer:
	    environment:
	      ES_JAVA_OPTS: -Xms512m -Xmx512m
	      cluster.name: akeneo
	      discovery.type: single-node
	    image: docker.elastic.co/elasticsearch/elasticsearch:6.0.0

	  mysql:
	    image: mysql:5.7
	    env_file: .env

	  php:
	    image: s7b4/akeneo
	    env_file: .env
	    links:
	    - mysql
	    - indexer
	    volumes_from:
	    - service:data:rw
	    depends_on:
	      - data
	      - mysql
	      - indexer

	  queue:
	    image: s7b4/akeneo
	    env_file: .env
	    command: /opt/launch-daemon.sh
	    links:
	    - mysql
	    - indexer
	    volumes_from:
	    - service:data:rw
	    depends_on:
	      - data
	      - mysql
	      - indexer

	  web:
	    image: s7b4/akeneo-front
	    env_file: .env
	    links:
	    - php
	    ports:
	    - 8080:80/tcp
	    volumes_from:
	    - service:data:ro
	    depends_on:
	    - data
	    - php

	version: '2.1'

Exemple de fichier [.env](https://raw.githubusercontent.com/s7b4/docker-akeneo/master/.env.dist) 

## Cron

	docker-compose exec php run-parts -v /opt/cron-scripts

## Interface

* Login initial: admin / admin