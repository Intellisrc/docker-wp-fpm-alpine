#!/bin/bash
ver=$(grep "FROM" ./Dockerfile | awk -F':' '{ print $2 }')
if [[ $ver == "" ]]; then
	echo "Version not found"
	exit
fi
echo "VERSION: $ver"
#docker build -t wp-fpm-alpine .
#docker tag wp-fpm-alpine:latest intellisrc/wp-fpm-alpine:$ver
#docker push intellisrc/wp-fpm-alpine:$ver

docker buildx build --load --push -t intellisrc/wp-fpm-alpine:$ver .
echo "Updated: intellisrc/wp-fpm-alpine:$ver"
