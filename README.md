# WordPress Dockerized with Unattended Installation

This repository contains a Dockerfile and Docker Compose setup for creating a Dockerized WordPress instance with unattended installation.

## Features

- Installs WordPress with unattended setup
- Uses the [jwilder/dockerize](https://github.com/jwilder/dockerize) script for waiting on the database
- Configurable via environment variables in the `.env` file

## Prerequisites

Make sure you have [Docker](https://www.docker.com/) and [Docker Compose](https://docs.docker.com/compose/) installed on your system.

## Usage

1. Clone this repository:

   ```bash
   git clone https://github.com/younest9/wordpress-unattended.git
   cd wordpress-unattended
   ```

2. Customize environment variables:

Modify the .env file to set your desired configuration. This file includes parameters such as database credentials, WordPress title, and admin user details (Details are [below](#environment-variables)).

3. Build and run the Docker containers:

   ```bash
   docker-compose up --build -d
   ```

4. Access WordPress:

Open your browser and navigate to http://localhost (or your specified host and port) to access your WordPress instance.

## Environment Variables

The following environment variables can be set in the `.env` file:

| Variable | Description | Default Value |
| --- | --- | --- |
| `WORDPRESS_DB_HOST` | The hostname of the database server | `db:${MYSQL_PORT}` |
| `WORDPRESS_DB_NAME` | The name of the database to use | `wordpress` |
| `WORDPRESS_DB_USER` | The username of the database user | `wordpress` |
| `WORDPRESS_DB_PASSWORD` | The password of the database user | `wordpress` |
| `WORDPRESS_HOSTNAME` | The hostname of the WordPress server | `localhost` |
| `WORDPRESS_PORT` | The port of the WordPress server | `80` |
| `MYSQL_ROOT_PASSWORD` | The password of the MySQL root user | `wordpress` |
| `WORDPRESS_TITLE` | The title of the WordPress site | `My WordPress Site` |
| `WORDPRESS_ADMIN_USER` | The username of the WordPress admin user | `admin` |
| `WORDPRESS_ADMIN_PASSWORD` | The password of the WordPress admin user | `admin` |
| `WORDPRESS_ADMIN_EMAIL` | The email of the WordPress admin user | `admin@test.com` |
| `MYSQL_PORT` | The port of the MySQL server | `3306` |

## Persisting Data
The MySQL data is stored in a bind mount volume. This means that the data will persist even after the containers are removed. The same goes for the WordPress data, which is stored in a bind mount volume as well.

The bind mount volumes are created in the `docker-compose.yml` file. You can change the location of the volumes by modifying the `volumes` section of the `db` and `wordpress` services.

You can also use Docker volumes instead of bind mount volumes. To do so, replace the `volumes` section of the `db` and `wordpress` services with the following:

```yaml
volumes:
  - db_data:/var/lib/mysql
  - wordpress_data:/var/www/html
```

But keep in mind that Docker volumes need to be manually created before running the containers. You can create the volumes by running the following commands:

```bash
docker volume create db_data
docker volume create wordpress_data
```

## Acknowledgments
This setup uses the [official WordPress image](https://hub.docker.com/_/wordpress) and the [jwilder/dockerize](https://github.com/jwilder/dockerize) script.