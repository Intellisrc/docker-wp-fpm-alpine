#!/bin/bash
./update.sh
sed -i "s/FROM intellisrc/alpine:3.14/FROM intellisrc/alpine:3.10" Dockerfile
./update.sh
sed -i "s/FROM intellisrc/alpine:3.10/FROM intellisrc/alpine:3.8" Dockerfile
./update.sh
sed -i "s/FROM intellisrc/alpine:3.8/FROM intellisrc/alpine:3.14" Dockerfile
echo "Done"