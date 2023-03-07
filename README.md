# docker-wp-fpm-alpine
Wordpress running with PHP-FPM (v8.1) and lighttpd inside a Docker container running Alpine.

## Docker:

`intellisrc/wp-fpm-alpine:3.17`

## Setup:

Arguments:

```
ARG PHP_VER=81
```
(81 = PHP 8.1)

Environment:

```
PHP_MIN_WORKERS=1
PHP_MAX_WORKERS=20
WP_VER=latest
WP_PREFIX=wp_
DB_NAME=
DB_USER=
DB_PASSWORD=
DB_PASS=
DB_HOST=localhost
DB_CHARSET=utf8
```

It will download the latest (or the version specified in "WP_VER"), and start the services `php-fpm` (background) and `lighttpd` (foreground).

## Docker Swarm:

Example:

```
services:
  wp:
    image: intellisrc/wp-fpm-alpine:3.17
    volumes:
      - type: bind
        source: "/docker/sites/example/"
        target: "/var/www/wp-content/"
    networks:
      - proxy_net
      - database_net
    environment:
      DB_HOST: database_host
      DB_USER: example_user
      DB_NAME: wp_example
      DB_PASS: *****************
      WP_PREFIX: ex_
      HTTPS_DOMAIN: example.com
      PHP_MIN_WORKERS: 0
      PHP_MAX_WORKERS: 10
      #WP_LANG: ja
    healthcheck:
      test: wget -q -O - http://localhost/health_check.php | grep "ok"
      interval: 60s
      retries: 2
      timeout: 30s
    deploy:
      mode: replicated
      replicas: 1
      endpoint_mode: dnsrr
      placement:
        constraints: 
          - node.labels.wordpress == true
```

## Why?

Comparing with the official build, this one is smaller (around 45MB) and uses less memory (less than 125MB RAM with `PHP_MIN_WORKERS=1`, or less than 80MB with `PHP_MIN_WORKERS=0` in low traffic). 
