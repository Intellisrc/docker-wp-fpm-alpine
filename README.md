# docker-wp-fpm-alpine
Wordpress running with PHP-FPM (v7) and lighttpd in Alpine inside a Docker container

Arguments:

```
ARG PHP_VER=7 (8 is not working yet)
```

Environment:

```
WP_VER=latest
DB_NAME=
DB_USER=
DB_PASSWORD=
DB_PASS=
DB_HOST=localhost
DB_CHARSET=utf8
```

It will download the latest (or the version specified in "WP_VER"), and start the services `php-fpm` (background) and `lighttpd` (foreground).
