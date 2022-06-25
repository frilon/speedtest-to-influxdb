#! /usr/bin/env bash

TRY_MAX=10

echo 'PWD'
pwd
echo 'ls -lAh'
ls -lAh

source ./functions.sh

while (($#)); do
    case "${1}" in
    --start-docker-compose | -u)
        startDockerComposeStack
        ;;
    --run-tests | -t)
        checkInfluxDb
        checkGrafanaProvisioning
        ;;
    --stop-docker-compose | -d)
        stopDockerComposeStack
        ;;
    esac
    shift
done
