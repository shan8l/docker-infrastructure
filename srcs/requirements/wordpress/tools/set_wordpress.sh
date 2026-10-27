#!/bin/bash
set -e

WP_PATH="/var/www/html"

#check database password
if [ ! -f "/run/secrets/db_password" ]; then
     echo "Error: secret file not found de_password"
     exit 1
fi

DB_PASSWORD=$(cat /run/secrets/db_password)

#check wordpress credentails.txt
if [ ! -f "/run/secrets/credentials" ]; then
    echo "Error: Secret file not found credentials"
    exit 1
fi

# user grep to find the line, and cut to split it at the '=' sign and take the 2nd part
WP_ADMIN_PASSWORD=$(grep '^WP_ADMIN_PASSWORD=' /run/secrets/credentials | cut -d '=' -f2-)
WP_USER_PASSWORD=$(grep '^WP_USER_PASSWORD=' /run/secrets/credentials | cut -d '=' -f2-)

# check the pass is excute
if [ -z "$WP_ADMIN_PASSWORD" ] || [ -z "$WP_USER_PASSWORD" ]; then
    echo "Error: Failed to extract WordPress passwords from credentials file."
    exit 1
fi

#check the domain name
if [ -z "${DOMAIN_NAME}" ]; then
    echo "Error: DOMAIN_NAME environment variable not set"
    exit 1
fi

#check the domain name like the requirements
if [[ ! "${DOMAIN_NAME}" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]*\.42\.fr$ ]]; then
    echo "Error: DOMAIN_NAME '${DOMAIN_NAME}' may not be in expected format (*.42.fr)"
    exit 1
fi

#validate worpress admin username against project rules
ADMIN_USER_LOWER=$(printf '%s' "$WORDPRESS_ADMIN_USER" | tr '[:upper:]' '[:lower:]')

if [[ "$ADMIN_USER_LOWER" == *admin* ]] || [[ "$ADMIN_USER_LOWER" == *administrator* ]]; then
    echo "Error: WORDPRESS_ADMIN_USER cannot contain 'admin' or 'administrator'"
    exit 1
fi

echo "Validated configuration successfully"


if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "WordPress configurationnot found. starting fresh installation..."

    echo "Waiting for database to be ready..."

# download wordpress
    wp core download --allow-root --path="$WP_PATH"
# create wp-config.php
    wp config create --allow-root \
        --dbname="${WORDPRESS_DB_NAME}" \
        --dbuser="${WORDPRESS_DB_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="${WORDPRESS_DB_HOST}" \
        --path="$WP_PATH"
# install wordpress
    wp core install --allow-root \
        --url="${DOMAIN_NAME}" \
        --title="${WORDPRESS_TITLE}" \
        --admin_user="${WORDPRESS_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WORDPRESS_ADMIN_EMAIL}" \
        --path="$WP_PATH"

#create an user
    wp user create --allow-root \
        "${WORDPRESS_USER}" \
        "${WORDPRESS_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=author \
        --path="$WP_PATH"

    chown -R www-data:www-data "$WP_PATH"
    echo "WordPress setup complete."
else
    echo "Wordpress already initialized, skipping setup."
fi


echo "Sarting PHP-FPM..."
exec php-fpm8.2 -F
