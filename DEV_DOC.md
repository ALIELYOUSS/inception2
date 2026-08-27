# Developer Documentation

## Prerequisites

Install the following on the Linux host or VM:

- Docker Engine
- The Docker Compose plugin
- GNU Make
- A local DNS entry or `/etc/hosts` entry for the WordPress domain

The default domain is `alel-you.42.fr`. Add this entry when testing locally:

```text
127.0.0.1 alel-you.42.fr
```

## Configuration and secrets

Create `srcs/.env` before building the project. Compose loads this file for all services. It must define:

```dotenv
SQL_DATABASE=your_database
SQL_USER=your_database_user
SQL_PASSWORD=your_database_password
SQL_HOST=mariadb

WP_URL=https://alel-you.42.fr
WP_TITLE=your_site_title
WP_ADMIN_USER=your_admin_username
WP_ADMIN_PASS=your_admin_password
WP_ADMIN_EMAIL=admin@example.com

WP_USER=your_username
WP_PASS=your_password
WP_EMAIL=user@example.com
WP_USER_ROLE=author
```

Use strong, unique passwords and keep `srcs/.env` out of version control. The values are passed to MariaDB and WordPress through Compose environment variables. The Nginx image creates a one-year self-signed certificate for the configured domain during image build.

## Build and launch

Run commands from the repository root. The Makefile points Compose at `srcs/docker-compose.yml`.

```bash
make build
make up
```

`make up` creates `$HOME/data/wordpress` and `$HOME/data/mariadb`, then starts the services in detached mode. `make` runs both `make build` and `make up`.

Check the stack with:

```bash
make check
docker compose --file srcs/docker-compose.yml ps -a
docker compose --file srcs/docker-compose.yml logs --tail=50
```

MariaDB is started first and has a health check. WordPress depends on that healthy MariaDB service, then downloads and installs WordPress on its first start. Nginx forwards PHP requests to `wordpress:9000` and publishes HTTPS on host port `443`.

## Container and volume commands

Useful lifecycle commands are:

```bash
make down       # Stop and remove containers and Compose volumes
make clean      # Run make down and remove the project images
make fclean     # Run make clean and remove all persisted host data
make rm-vlms    # Remove $HOME/data
```

Equivalent Compose commands can be run directly:

```bash
docker compose --file srcs/docker-compose.yml up -d
docker compose --file srcs/docker-compose.yml stop
docker compose --file srcs/docker-compose.yml start
docker compose --file srcs/docker-compose.yml down
docker compose --file srcs/docker-compose.yml down -v
docker compose --file srcs/docker-compose.yml exec wordpress bash
docker compose --file srcs/docker-compose.yml exec mariadb bash
```

Do not remove volumes or `$HOME/data` unless deleting the installation is intended. Use `docker compose ... config` to validate Compose interpolation and configuration before launch.

## Data storage and persistence

The Compose file declares two named volumes backed by host directories:

- `wordpress` stores WordPress files in `$HOME/data/wordpress` and is mounted at `/var/www/html` in WordPress and Nginx.
- `mariadb` stores the database in `$HOME/data/mariadb` and is mounted at `/var/lib/mysql` in MariaDB.

The data survives container removal and image rebuilds because it is stored on the host. `make down` removes the Compose volume objects but does not remove the host directories. `make fclean` and `make rm-vlms` remove the host data and therefore permanently delete the WordPress installation and database.

To inspect the configured volume mappings, run:

```bash
docker volume ls
docker volume inspect inception2_wordpress
docker volume inspect inception2_mariadb
```

The Compose project name can change the volume name, so use `docker volume ls` if the names differ.

## Project layout

- `Makefile`: project lifecycle targets.
- `srcs/docker-compose.yml`: services, network, health check, and volumes.
- `srcs/requirements/mariadb`: MariaDB image and initialization script.
- `srcs/requirements/wordpress`: PHP-FPM image and WP-CLI installation script.
- `srcs/requirements/nginx`: HTTPS image and Nginx configuration.
- `srcs/.env`: local configuration and credentials; keep it private.
