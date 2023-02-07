# Dockerfile for lighttpd
FROM intellisrc/alpine:3.14
EXPOSE 80
VOLUME ["/var/www/wp-content"]

ARG PHP_VER=7
ENV WP_VER=latest
ENV DB_NAME=
ENV DB_USER=
ENV DB_PASSWORD=
ENV DB_PASS=
ENV DB_HOST=localhost
ENV DB_CHARSET=utf8

RUN apk add --update --no-cache \
	curl rsync lighttpd php$PHP_VER-fpm php$PHP_VER-ctype php$PHP_VER-common php$PHP_VER-fpm php$PHP_VER-cli php$PHP_VER php$PHP_VER-curl php$PHP_VER-gd php$PHP_VER-json php$PHP_VER-mysqli php$PHP_VER-zip php$PHP_VER-session php$PHP_VER-xmlrpc php$PHP_VER-xml php$PHP_VER-dom php$PHP_VER-xmlreader php$PHP_VER-xmlwriter php$PHP_VER-mbstring php$PHP_VER-iconv && \
	rm -rf /var/cache/apk/*

RUN mkdir -p /var/log/lighttpd/ && \
    mkdir -p /var/cache/lighttpd/uploads/ && \
    mkdir -p /var/cache/lighttpd/compress/ && \
	chown -R lighttpd.lighttpd /var/log/lighttpd/ && \
	chown -R lighttpd.lighttpd /var/cache/lighttpd/ && \
	ln -s /usr/sbin/php-fpm$PHP_VER /usr/sbin/php-fpm && \
	ln -s /etc/php$PHP_VER /etc/php

COPY image/lighttpd.conf /etc/lighttpd/
COPY image/php-fpm.conf /etc/php$PHP_VER/php-fpm.d/www.conf
COPY image/php.ini /etc/php$PHP_VER/
COPY image/start.sh /usr/local/bin/

WORKDIR /var/www
CMD ["start.sh"]
