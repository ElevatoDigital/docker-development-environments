# Docker Development Environments
To rapidly start local development. Purpose built for Delta's development staff, but open for public use.

## Goals
* Add a complete docker environment to a repo with minimal effort
* Support a standard project layout, compatible with [TriPoint Hosting](https://www.tripointhosting.com)
* Provide multiple configurations for different project requirements

## Supported Environments

| Name | docker-compose file | OS | Web Server | NodeJS / NPM | Database | PHP | Composer | Deployer | WP CLi |  
| --- | --- | --- |--- |--- |--- |--- |--- |--- |--- |
| wordpress | docker-compose-wordpress.yml | Linux | Apache | 12 / 6 |  MySQL 8 | PHP 8 | X | X | X |
| lamp-8 | docker-compose-lamp-8.yml | Linux | Apache | 12 / 6 | MySQL 5.7 | PHP 8 | X | X | |
| lamp-7 | docker-compose-lamp-7.yml | Linux | Apache | 12 / 6 | MySQL 5.7 | PHP 7 | X | X | |
| lapp-7 | docker-compose-lapp-7.yml | Linux | Apache | 12 / 6 | Postgres 9.6 | PHP 7 | X | X | |

## Prerequisites

1. Install [Docker-Compose](https://docs.docker.com/compose/install/) (i.e. Docker Desktop on Windows)
2. Organize your repository's source code under a `src/` folder to match TriPoint's hosting directory structure. `src/httpdocs/` is the public web path and `src/private/` is a private web path.

```bash
src/
├── httpdocs/
└── private/
```

## Getting Started

1. Choose which development environment you need (e.g. lamp-8)
1. Copy and paste the yaml file for that environment (i.e. `docker-compose-lamp-8.yml`) to `docker-compose.yml` in your project's root directory.
1. `docker-compose up -d`

Images will be pulled down from this project's container registry and your `src/` folder mounted to the web container. Default access settings:

* default web url: http://localhost:8081
* default mysql port: 3307
* default mysql user: root
* default mysql pass: Pass@1234
* default postgres port: 5433
* default postgres user: root
* default postgres pass: Pass@1234
* default memcached port: 11211

## Setting up a database

No database is created by default, so you will need to login and create a database for your project. Or, you may create a `mysql-on-init` or `postgres-on-init` folder and add .sql/.sh files to preload a database when your container is initialized. Each environment has a sample `mysql-on-init` or `postgres-on-init` folder that you may copy into your repository.

mysql-on-init/00000-create-db.sql
```shell
/*!40101 SET NAMES utf8 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`development` /*!40100 DEFAULT CHARACTER SET utf8 */;
```
postgres-on-init/00000-create-db.sql
```shell
#!/bin/bash

DBNAME=development
DBUSER=development
DUMPFILE="/docker-entrypoint-initdb.d/import-dump"

echo "Restoring DB using $file"
psql -U postgres --dbname=postgres -c "CREATE USER $DBUSER;"
psql -U postgres --dbname=postgres -c "CREATE DATABASE $DBNAME;"
psql -U postgres --dbname=postgres -c "GRANT ALL PRIVILEGES ON DATABASE $DBNAME TO $DBUSER;"
psql -U postgres --dbname=$DBNAME < "$DUMPFILE" || exit 1
```

## Logging into the web container
It's recommended that you perform command line operations like `npm install`, `php artisan` and `php composer.phar` from inside the web container. From your repository's root (where docker-compose.yml was installed), execute:

`docker-compose exec web bash`

From the container, you can perform normal command line operations such as:
```shell
cd private/
composer install
php artisan migrate
npm install
```

## Customizing Configs

Under each environment is a `conf/` directory (i.e. `build-lamp-8/conf/`). You may copy this folder into your repository root directory. Customize the included configs (e.g. php.ini) as needed. Then uncomment the volumes in your local `docker-compose.yml` to mount those configs:

web:
```yaml
volumes:
  - "./conf/php/custom.ini:/usr/local/etc/php/conf.d/custom.ini"
```
mysql:
```yaml
volumes:
  - "./conf/mysql/custom.cnf:/etc/mysql/conf.d/custom.cnf"
```
postgres:
```yaml
volumes:
  - "./postgres-on-init:/docker-entrypoint-initdb.d"
```

## Deployer Support

If you are using PHP Deployer to handle deployments, a volume mount point exists for `deploy.php`. This allows you to mount the Deployer config from the project root inside the container so that deployments can be made from inside the container.

Uncomment thi line on the web service in `docker-compose.yml`:
```yaml
- "./deploy.php:/var/www/vhosts/myvhost/private/deploy.php"
```

If your containers were running, restart them:

`docker-compose restart`

Login to the web server:

`docker-compose exec web bash`

Run deployer commands:
```shell
cd private/
dep deploy staging
```
