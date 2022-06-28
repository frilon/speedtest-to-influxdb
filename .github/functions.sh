#! /usr/bin/env bash

function customExit() {
    ERROR_TYPE=$1
    MESSAGE=$2
    CUSTOM_EXIT_CODE=$3

    echo "${ERROR_TYPE} :: ${MESSAGE}"
    exit "${CUSTOM_EXIT_CODE}"
}

function localDockerCompose() {
    if docker compose version &>/dev/null; then
        DOCKER_COMPOSE_CMD="docker compose"
    elif docker-compose version &>/dev/null; then
        DOCKER_COMPOSE_CMD="docker-compose"
    else
        customExit "CRITICAL" "Docker Compose seems not to be installed." "255"
    fi
}

function startDockerComposeStack() {
    localDockerCompose
    "${DOCKER_COMPOSE_CMD}" up -d || customExit "ERROR" "Could not start docker compose stack." "255"
}

function checkInfluxDb() {
    for ((i = 1; i <= TRY_MAX; i++)); do
        echo -n "${FUNCNAME[0]} :: ${i}/${TRY_MAX} $(date '+%F %T'):: "
        if curl -sLI --url localhost:8086/ping | grep -q "X-Influxdb-Version:"; then
            echo "SUCCESS"
            return 0
        else
            if [[ ${i} -eq 10 ]]; then
                customExit "CRITICAL" "InfluxDB seems not to be up and running." "255"
            else
                echo "Waiting for next run in 5 seconds..."
                sleep 5
            fi
        fi
    done
}

function checkGrafanaProvisioning() {
    for ((i = 1; i <= TRY_MAX; i++)); do
        echo -n "${FUNCNAME[0]} :: ${i}/${TRY_MAX} $(date '+%F %T'):: "
        RESPONSE=$(curl \
            --silent \
            --header 'Content-Type: application/json' \
            --header 'Accept: application/json' \
            --url 'http://adminuser:adminpassword@localhost:3000/api/search?dashboardIds' | jq -r '.[0].title')
        if [[ "${RESPONSE}" = "SpeedFlux" ]]; then
            echo "SUCCESS"
            return 0
        else
            if [[ ${i} -eq 10 ]]; then
                customExit "CRITICAL" "Grafana Dashboard seems not to be provisioned correctly." "255"
            else
                echo "Waiting for next run in 5 seconds..."
                sleep 5
            fi
        fi
    done
}

function stopDockerComposeStack() {
    localDockerCompose
    "${DOCKER_COMPOSE_CMD}" down || customExit "ERROR" "Could not shutdown docker compose stack." "255"
}
