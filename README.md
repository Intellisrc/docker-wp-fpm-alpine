# docker-wp-fpm-alpine
Wordpress running with PHP-FPM (v7) and lighttpd inside a Docker container running Alpine

Arguments:

```
ARG PHP_VER=7 (8 is not working yet)
```

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


# Why?

Comparing with the official build, this one is smaller (around 45MB) and uses less memory (less than 80MB RAM in low traffic). 
