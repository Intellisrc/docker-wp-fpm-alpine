# Dockerfile for lighttpd
FROM intellisrc/php8-fpm-alpine:3.24
EXPOSE 80
VOLUME ["/var/www/wp-content"]

ENV WP_VER=latest
ENV WP_PREFIX=wp_
ENV DB_NAME=dbname
ENV DB_USER=user
ENV DB_PASS=pass
ENV DB_SSL=false
ENV DB_HOST=localhost
ENV DB_CHARSET=utf8
# Object cache options: "redis", "memcached" or "none"
ENV OBJ_CACHE=none

RUN apk add --update --no-cache \
	curl rsync patch lighttpd && \
	rm -rf /var/cache/apk/*

COPY image/lighttpd-wp.conf /etc/lighttpd/
COPY image/wp-config.patch /var/www/wp-config.patch
COPY image/health_check.php /var/www/health_check.php
COPY image/wp-start.sh /usr/local/bin/

WORKDIR /var/www
CMD ["wp-start.sh"]
