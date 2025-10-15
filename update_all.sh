#!/bin/bash
for ver in "3.8" "3.10" "3.14"; do
  echo "----------------------------- $ver -----------------------------"
  sed -i "s/FROM intellisrc\/alpine:.*/FROM intellisrc\/alpine:${ver}/" Dockerfile
  ./update.sh
done
echo "Done"