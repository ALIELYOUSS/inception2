*This project has been created as part of the 42 curriculum by alel-you.*

# Inception

## Description

This project is a small containerized WordPress website built for the 42 Inception project. It uses Docker Compose to run three services:

- **NGINX**: the only publicly exposed service; provides HTTPS on port `443` and forwards PHP requests to WordPress.
- **WordPress**: downloads and configures WordPress with WP-CLI, then runs PHP-FPM on port `9000`.
- **MariaDB**: stores the WordPress database and initializes the configured database user.

The services communicate over the private `alel-you` Docker bridge network. WordPress files and MariaDB data are persisted on the host in `$HOME/data/wordpress` and `$HOME/data/mariadb`.

## Instructions

- Linux or a Linux virtual machine
- Docker Engine with the Compose plugin
- GNU Make
- A local DNS or `/etc/hosts` entry for the configured domain

For the default configuration, add:

```text
127.0.0.1 alel-you.42.fr
```

The generated certificate is self-signed, so a browser warning is expected on first access.

### Configuration

Create `srcs/.env` before starting the stack. The Compose file requires the following variables:

```dotenv
SQL_DATABASE=your_database
SQL_USER=your_database_user
SQL_PASSWORD=your_database_password
SQL_HOST=mariadb

WP_URL=https://your-login.42.fr
WP_TITLE=your_site_title
WP_ADMIN_USER=your_admin_username
WP_ADMIN_PASS=your_admin_password
WP_ADMIN_EMAIL=admin@example.com

WP_USER=your_username
WP_PASS=your_password
WP_EMAIL=user@example.com
WP_USER_ROLE=author
```

Keep `.env` private. It contains credentials used by MariaDB and WordPress.

### Usage

From the repository root:

```bash
make
```

This creates the host data directories, builds the images, and starts the services in detached mode.

Useful Make targets:

| Command | Description |
| --- | --- |
| `make build` | Build the MariaDB, WordPress, and Nginx images. |
| `make up` | Create data directories and start the stack. |
| `make check` | Display the status of all containers. |
| `make down` | Stop and remove containers and Compose volumes. |
| `make clean` | Stop the stack and remove the project images. |
| `make fclean` | Perform `clean` and remove persisted host data. |
| `make rm-vlms` | Remove the contents of the host data directories. |

Open the website at `https://alel-you.42.fr` after the health checks complete.

## Project Description

### Docker design

Each service has its own Dockerfile and dedicated container. The images are built locally from Debian Bookworm-based images rather than using pre-built application images. Nginx is the only service exposed to the host, on port `443`; MariaDB and PHP-FPM are reachable only through the `alel-you` Docker network.

The source files are organized under `srcs/requirements`: MariaDB initialization, WordPress and PHP-FPM setup, and Nginx TLS configuration. `srcs/docker-compose.yml` defines the services, network, health checks, dependencies, and persistent storage. The root `Makefile` provides the project lifecycle commands.

### Main design comparisons

| Choice | This project | Alternative and trade-off |
| --- | --- | --- |
| Virtual machine vs Docker | Docker containers share the VM kernel and isolate each service with less overhead. | A virtual machine includes a complete guest operating system, providing stronger isolation but requiring more resources. The project itself is run inside a VM as required by 42. |
| Secrets vs environment variables | Configuration is supplied through `srcs/.env`, as required by the subject. | Docker secrets are better for confidential values because they are mounted as files and are not exposed as ordinary environment variables. Credentials must remain out of Git. |
| Docker network vs host network | Services use the private `alel-you` bridge network and service names for communication. | Host networking removes network isolation and exposes container services directly on the host network, so it is not used here. |
| Docker volumes vs bind mounts | Compose declares named volumes for WordPress and MariaDB, backed by `$HOME/data`. | A bind mount maps a host path directly and is easy to inspect, but has weaker portability and ownership isolation. The current Compose implementation uses `driver_opts` with `o: bind` to place the named volumes under `$HOME/data`; strict Inception validation may require replacing this with a Docker-managed named-volume approach that still stores data in `/home/alel-you/data`. |

## Resources

- [Docker Compose documentation](https://docs.docker.com/compose/)
- [Docker volumes documentation](https://docs.docker.com/engine/storage/volumes/)
- [Docker networking documentation](https://docs.docker.com/engine/network/)
- [NGINX SSL termination guide](https://docs.nginx.com/nginx/admin-guide/security-controls/terminating-ssl-http/)
- [WP-CLI documentation](https://developer.wordpress.org/cli/commands/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)

### AI usage

AI was used to help inspect the project files and draft and review this documentation. It was used for documentation structure, command descriptions, and checking the README against the Inception subject requirements.

## Project structure

```text
.
├── Makefile
└── srcs
    ├── .env
    ├── docker-compose.yml
    └── requirements
        ├── mariadb
        │   ├── Dockerfile
        │   └── tools/init-table.sh
        ├── nginx
        │   ├── Dockerfile
        │   └── conf/nginx.conf
        └── wordpress
            ├── Dockerfile
            └── tools/wp.sh
```

## Notes

- The Nginx image generates a 365-day self-signed certificate for the configured domain.
- MariaDB and WordPress start in dependency order through Docker health checks.
- `make fclean` permanently deletes the local WordPress and MariaDB data under `$HOME/data`; use it only when a fresh installation is intended.
- The stack is designed to expose HTTPS through Nginx rather than publishing MariaDB or PHP-FPM ports to the host.
