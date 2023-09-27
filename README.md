# Docker Development Environments
Rapidly start your local development using purpose built Docker containers for our development projects.

## Goals
* Add a complete docker environment to your repo with minimal effort
* Support a standard project layout, compatible with [TriPoint Hosting](https://www.tripointhosting.com)
* Provide multiple configurations for different project requirements

## Supported Environments

| Name      | docker-compose file          | OS | Web Server | NodeJS / NPM | Database     | PHP   | Composer | Cron | WP CLi |  
|-----------|------------------------------| --- |------------|--------------|--------------|-------|-- |------|--- |
| wordpress | docker-compose-wordpress.yml | Linux | Apache     | 12 / 6       | MySQL 8      | PHP 8 | ✅ | ✅    | ✅ |
| lamp-8    | docker-compose-lamp-8.yml    | Linux | Apache     | 12 / 6       | MySQL 8      | PHP 8 | ✅ | ✅    | ❌ |
| lamp-7    | docker-compose-lamp-7.yml    | Linux | Apache     | 12 / 6       | MySQL 5.7    | PHP 7 | ✅ | ✅    | ❌ |
| lapp-8    | docker-compose-lapp-8.yml    | Linux | Apache     | 12 / 6       | Postgres 14  | PHP 8 | ✅ | ✅    | ❌ |
| lapp-7    | docker-compose-lapp-7.yml    | Linux | Apache     | 12 / 6       | Postgres 11 | PHP 7 | ✅ | ✅    | ❌ |
| memcached | docker-compose-memcached.yml | Linux | ❌          | ❌            | ❌            | ❌     | ❌ | ❌    | ❌ |


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

## Default connection settings

default web settings:
* url: http://localhost:8081
  
default mysql settings:
* local port: 3307 (3306 from container)
* host: mysql
* user: root
* pass: Pass@1234
* name: development

default postgres settings:
* local port: 5433 (5432 from container)
* host: postgres
* user: root
* pass: Pass@1234
* name: development

default memcached settings:
* port: 11211

## Logging into the web container
It's recommended that you perform command line operations like `composer`, `php artisan`, and `npm install` from inside the web container. From your repository's root (where docker-compose.yml was installed), execute:

`docker-compose exec web bash`

From the container, you can perform normal command line operations such as:
```shell
cd private/
composer install
php artisan migrate
npm install
```

## Updating existing containers

From time to time you may need to rebuild your Docker containers to pull an updated version of these images for your project. Typically, the web container sees the most updates and can be rebuilt painlessly.

Rebuild the web container:
```shell
docker-compose stop web
docker-compose rm web
docker-compose pull
docker-compose up -d web
```

If an updated database image is available (less common), you may want to backup your existing database before rebuilding your database container. Rebuilding the database container will delete your existing database permanently.

Rebuild the db container (this will delete your db data):
```shell
docker-compose stop mysql
docker-compose rm mysql
docker-compose pull
docker-compose up -d mysql
```

## Customizing database

To override the default `development` database, you may create a `mysql-on-init` or `postgres-on-init` folder and add .sql/.sh files to preload a database when your container is initialized. Each environment has a sample `mysql-on-init` or `postgres-on-init` folder that you may copy into your repository to get started. Finally, you need to uncomment the volume in your `docker-compose.yml` to use that folder.

copy mysql-on-init/00000-create-db.sql to repository
```shell
/*!40101 SET NAMES utf8 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`development` /*!40100 DEFAULT CHARACTER SET utf8 */;
```
then uncomment in `docker-compose.yml`
```shell
- "./mysql-on-init:/docker-entrypoint-initdb.d"
```

copy postgres-on-init/00000-create-db.sql to repository
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
then uncomment in `docker-compose.yml`
```shell
- "./postgres-on-init:/docker-entrypoint-initdb.d"
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

## Adding Memcached

Some projects may require use of memcached (e.g. clustered production cache store). You can add memcached with a few steps:

1. Add the memcached environment to your project's docker-compose.yml:
```yaml
  memcached:
    image: ghcr.io/elevatodigital/docker-development-environments/memcached:latest
    ports:
      - "11211:11211"
```

2. Link the memcached environment into the needed container (e.g. web)
```yaml
  web:
    links:
      - 'memcached:memcached'
```

3. If adding memcached to an existing PHP project, verify that the PHP extensions is loaded (i.e. conf/php/custom.ini)
```ini
extension=memcached.so
```

You can now access memcached from your container using the hose `memcached` and port `11211`.

## Deployer Support

If you are using PHP Deployer to handle deployments, a volume mount point exists for `deploy.php`. This allows you to mount the Deployer config from the project root inside the container so that deployments can be made from inside the container.

Uncomment this line on the web service in `docker-compose.yml`:
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

## Publishing Image Changes (Development Team Only)

If you have made changes to the Docker configuration, those changes should be reflected in the associated packages by
publishing rebuilt images to the GitHub Container Registry. First, rebuild the containers and then push.


### Logging into ghcr.io with Docker (password)

This method has been deprecated by GitHub and may give you issues in the future. 

```shell
docker login ghcr.io # Use development+deploy@elevatodigital.com account in LastPass
```

### Logging into ghcr.io with Docker (personal access token)

This is the preferred method for authenticating with GitHub's container repository.

Note: please refer to this documentation which these steps are derived from https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry

1. Login with your GitHub account (or an account with write access to the `elevatodigital/docker-development-environments` repository)
2. Settings > Developer Settings > Personal Access Tokens
3. Generate New Token
4. Select an appropriate Expiration setting
5. Name the token and select the `write:packages` and `delete:packages` scopes.
6. Record the generated token for the next steps (YOUR_TOKEN)
7. Login to docker from the CLI

*nix systems
```shell
# save token to environmental variable
export CR_PAT=YOUR_TOKEN

# login using the token stored in your environmental variable
echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
```

windows system
```shell
# save token to a text file
"YOUR_TOKEN" | Out-File -FilePath ~\.docker-development-environments-pat

# read pat from text file and supply to docker login
cat ~\.docker-development-environments-pat | docker login ghcr.io -u USERNAME --password-stdin
```

### Build & Push

Each Docker environment with changes needs to be  built and pushed. This is accomplished by changing directories to each environment and running the `docker build` and `docker push` commands (formerly `docker-compose build` and `docker-compose push`).

```shell
cd build-lamp-7
docker compose build
docker compose push
cd ..

cd build-lamp-8
docker compose build
docker compose push
cd ..

cd build-lapp-7
docker compose build
docker compose push
cd ..

cd build-lapp-8
docker compose build
docker compose push
cd ..

cd build-wordpress
docker compose build
docker compose push
cd ..
```
