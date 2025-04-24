#!/bin/bash
# docker-login.sh at ./deployment/scripts/docker-login.sh
# params: the password, the registry URL, and the username
echo "$1" | docker login $2 -u $3 --password-stdin