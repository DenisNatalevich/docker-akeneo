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

	data:
	  image: tianon/true
	  volumes:
	    - /var/www/html

	web:
	  image: s7b4/akeneo:web
	  links:
	    - php
	  ports:
	    - "8080:80"
	  env_file: .env
	  volumes_from:
	    - data:ro

	php:
	  image: s7b4/akeneo:php
	  links:
	    - mysql
	    - indexer
	  env_file: .env
	  volumes_from:
	    - data:rw

	mysql:
	  image: mysql:5.7
	  env_file: .env

	indexer:
	  image: docker.elastic.co/elasticsearch/elasticsearch:6.0.0
	  environment:
	    - cluster.name=akeneo
	    - discovery.type=single-node
	    - "ES_JAVA_OPTS=-Xms512m -Xmx512m"


Exemple de fichier [.env](https://raw.githubusercontent.com/s7b4/docker-akeneo/master/.env.dist) 

## Interface

* Login initial: admin / admin