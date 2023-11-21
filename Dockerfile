FROM wordpress:latest

LABEL maintainer="Younes EL ARJOUNI <y.elarjouni.sq@gmail.com"
LABEL description="Dockerfile to build a WordPress container image with unattended installation"

# Install dependencies and prerequisites
RUN apt-get update \
    && apt-get install -y wget nano jq default-mysql-client unzip --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Install wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Volume for WordPress files
VOLUME /var/www/html

# Retrieve exec "$@" from docker entrypoint and replace it with the following commands:
# - Install dockerize
# - Wait for the database to be up
# - Install WordPress core
RUN sed -i 's/exec "$@"/\n \
export DOCKERIZE_VERSION=$(echo $(curl -s https:\/\/api.github.com\/repos\/jwilder\/dockerize\/releases\/latest) | jq -r \"\.tag_name\")\n \
echo $DOCKERIZE_VERSION\n \
# Test if the architecture is aarch64, then it is the same as arm64\n \
if [ $(uname -m) = \"aarch64\" ]; then\n \
    export DOCKERIZE_ARCH=\"arm64\"\n \
# Test if the architecture is armv7l, then it is the same as armhf\n \
elif [ $(uname -m) = \"armv7l\" ]; then\n \
    export DOCKERIZE_ARCH=\"armhf\"\n \
# Test if the architecture is armv6l, then it is the same as armel\n \
elif [ $(uname -m) = \"armv6l\" ]; then\n \
    export DOCKERIZE_ARCH=\"armel\"\n \
# Test if the architecture is x86_64, then it is the same as amd64\n \
elif [ $(uname -m) = \"x86_64\" ]; then\n \
    export DOCKERIZE_ARCH=\"amd64\"\n \
# Test if the architecture is i386, then it is the same as 386\n \
elif [ $(uname -m) = \"i386\" ]; then\n \
    export DOCKERIZE_ARCH=\"386\"\n \
# Test if the architecture is ppc64le, then it is the same as ppc64pl\n \
elif [ $(uname -m) = \"ppc64le\" ]; then\n \
    export DOCKERIZE_ARCH=\"ppc64le\"\n \
# Add more architecture checks as needed\n \
else\n \
    # If the architecture is not explicitly handled, use uname -m value as is\n \
    export DOCKERIZE_ARCH=$(uname -m)\n \
fi\n \
echo $DOCKERIZE_ARCH\n \
export DOCKERIZE_PACKAGE=dockerize-linux-${DOCKERIZE_ARCH}-${DOCKERIZE_VERSION}.tar.gz\n \
echo $DOCKERIZE_PACKAGE\n \
export DOCKERIZE_RELEASE=${DOCKERIZE_VERSION}\/${DOCKERIZE_PACKAGE}\n \
echo $DOCKERIZE_RELEASE\n \
wget https:\/\/github.com\/jwilder\/dockerize\/releases\/download\/$DOCKERIZE_RELEASE\n \
tar -C \/usr\/local\/bin -xzvf $DOCKERIZE_PACKAGE\n \
rm $DOCKERIZE_PACKAGE\n \
dockerize -wait tcp:\/\/$WORDPRESS_DB_HOST -timeout 60s\n \
wp core install --allow-root --path=\/var\/www\/html --url=$WORDPRESS_URL --title=\"\$WORDPRESS_TITLE\" --admin_user=\$WORDPRESS_ADMIN_USER --admin_password=\$WORDPRESS_ADMIN_PASSWORD --admin_email=\$WORDPRESS_ADMIN_EMAIL\n \
exec "$@"/g' /usr/local/bin/docker-entrypoint.sh


# Change owner of WordPress files
RUN chown -R www-data:www-data /var/www/html

# Change permissions for WordPress content folder
RUN chmod -R 1777 /var/www/html/wp-content

# Expose port 80
EXPOSE 80

# Launch entrypoint
ENTRYPOINT ["docker-entrypoint.sh"]

# Launch Apache2
CMD ["apache2-foreground"]
