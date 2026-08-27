# User Documentation

## Services

This project provides a WordPress website made of three Docker services:

- **NGINX** terminates HTTPS and serves the website on port `443`.
- **WordPress** runs PHP-FPM and manages the WordPress application.
- **MariaDB** stores the WordPress database.

Only NGINX is published to the host. WordPress and MariaDB communicate through the private Docker network.

## Start and stop the project

1. Make sure Docker Engine, the Docker Compose plugin, and GNU Make are installed.
2. Make sure `srcs/.env` has been configured. The required settings are listed in [DEV_DOC.md](DEV_DOC.md).
3. Add the configured domain to `/etc/hosts` if it does not resolve locally. For the default domain:

   ```text
   127.0.0.1 alel-you.42.fr
   ```

4. From the repository root, start the stack:

   ```bash
   make
   ```

   This builds the images, creates the host data directories, and starts the services in the background.

To stop and remove the containers and Compose volumes, run:

```bash
make down
```

To stop the stack, remove its images, and delete all persisted WordPress and MariaDB data, run:

```bash
make fclean
```

`make fclean` is destructive. Use it only when a fresh installation is intended.

## Access the website

Open the `WP_URL` value from `srcs/.env` in a browser. With the default configuration, use:

- Website: <https://alel-you.42.fr>
- Administration panel: <https://alel-you.42.fr/wp-admin/>

The certificate is self-signed and generated locally, so the browser will display a certificate warning on first access. The WordPress administrator username, password, and email are the `WP_ADMIN_USER`, `WP_ADMIN_PASS`, and `WP_ADMIN_EMAIL` values in `srcs/.env`.

## Credentials

Credentials are configured in `srcs/.env`. This file contains the MariaDB database name, database user and password, the WordPress administrator credentials, and the additional WordPress user credentials.

Keep `srcs/.env` private and do not commit it to Git or share it publicly. To change credentials, stop the stack, edit the relevant values, and follow the project reset procedure if the database or WordPress installation has already been initialized. Existing credentials may remain in the persisted data until that data is removed with `make fclean`.

## Check service status

From the repository root, display the status of all containers with:

```bash
make check
```

All three services should be listed as running. MariaDB has a Compose health check, and WordPress waits for MariaDB before installing WordPress. You can also inspect recent logs with:

```bash
docker compose --file srcs/docker-compose.yml logs --tail=50
```

If the website is not reachable, first confirm that Docker is running, the containers are up, the `/etc/hosts` entry matches `WP_URL`, and the browser is using `https://` on port `443`.
