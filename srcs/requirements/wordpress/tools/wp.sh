#!/bin/bash


set -x 


if [ -f wp-config.php ] ; then
 	echo "Wordpress is already installed!";
else	
	echo "Installing Wordpress...";


	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /bin/wp

	cd /var/www/html

	echo "[*] Waiting for database to be ready..."
	until mysql -h"$SQL_HOST" -u"$SQL_USER" -p"$SQL_PASSWORD" -e "SELECT 1" >/dev/null 2>&1; do
    	echo "Database not ready yet, waiting 2 seconds..."
    	sleep 2
	done
	echo "[+] Database is ready!"
	wp core download --allow-root
	wp config create --dbname=$SQL_DATABASE --dbuser=$SQL_USER --dbpass=$SQL_PASSWORD --dbhost=$SQL_HOST --allow-root
	wp core install --url=$WP_URL --title=$WP_TITLE --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASS --admin_email=$WP_ADMIN_EMAIL --skip-email --allow-root
	wp user create $WP_USER $WP_EMAIL --role=$WP_USER_ROLE --user_pass=$WP_PASS --allow-root
	wp option update home $WP_URL --allow-root
	wp option update siteurl $WP_URL --allow-root

fi

chown -R www-data:www-data .

chmod -R 775 .

sed -i 's#listen = /run/php/php8.2-fpm.sock#listen = 0.0.0.0:9000#' /etc/php/8.2/fpm/pool.d/www.conf

exec php-fpm8.2 -F
