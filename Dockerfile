# Dockerfile for lighttpd
FROM intellisrc/alpine:3.6
EXPOSE 80
VOLUME ["/var/www/wp-content"]

ENV PHP_VER=5
ENV PHP_MIN_WORKERS=1
ENV PHP_MAX_WORKERS=20
ENV WP_VER=latest
ENV WP_PREFIX=wp_
ENV DB_NAME=dbname
ENV DB_USER=user
ENV DB_PASS=pass
ENV DB_HOST=localhost
ENV DB_CHARSET=utf8
# Object cache options: "redis", "memcached" or "none"
ENV OBJ_CACHE=none

RUN apk add --update --no-cache \
	curl rsync patch lighttpd \
	php$PHP_VER-fpm php$PHP_VER-ctype php$PHP_VER-common php$PHP_VER-intl \
	php$PHP_VER-curl php$PHP_VER-gd php$PHP_VER-json php$PHP_VER-mysqli \
	php$PHP_VER-zip php$PHP_VER-dom php$PHP_VER-mysql \
	php$PHP_VER-iconv php$PHP_VER-opcache php$PHP_VER-exif && \
	rm -rf /var/cache/apk/*

RUN mv /etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.orig
COPY image/lighttpd.conf /etc/lighttpd/
COPY image/php-fpm.conf /etc/php$PHP_VER/php-fpm.d/www.conf
COPY image/php.ini /etc/php$PHP_VER/
COPY image/wp-config.patch /var/www/wp-config.patch
COPY image/health_check.php /var/www/health_check.php
COPY image/start.sh /usr/local/bin/

# PHP5 is in /usr/bin/
RUN mkdir -p /var/log/lighttpd/ && \
    mkdir -p /var/cache/lighttpd/uploads/ && \
    mkdir -p /var/cache/lighttpd/compress/ && \
	chown -R lighttpd.lighttpd /var/log/lighttpd/ && \
	chown -R lighttpd.lighttpd /var/cache/lighttpd/ && \
	ln -s /usr/bin/php-fpm$PHP_VER /usr/sbin/php-fpm && \
	ln -s /etc/php$PHP_VER /etc/php 

WORKDIR /var/www
CMD ["start.sh"]
