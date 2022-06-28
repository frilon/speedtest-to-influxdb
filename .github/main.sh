#! /usr/bin/env bash

TRY_MAX=10

source ./.github/functions.sh

DOCKER_COMPOSE_CMD=$(localDockerCompose)
export DOCKER_COMPOSE_CMD
echo "${DOCKER_COMPOSE_CMD}"

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
