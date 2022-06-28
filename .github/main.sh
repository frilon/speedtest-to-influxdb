#! /usr/bin/env bash

TRY_MAX=10

# shellcheck source=./functions.sh
source ./.github/functions.sh

cp .env-example .env

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
