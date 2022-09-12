#!/bin/bash
docker build -t wp-fpm-alpine .
docker tag wp-fpm-alpine:latest intellisrc/wp-fpm-alpine:latest
docker push intellisrc/wp-fpm-alpine:latest
