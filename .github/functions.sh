#! /usr/bin/env bash

function customExit() {
    ERROR_TYPE=$1
    MESSAGE=$2
    CUSTOM_EXIT_CODE=$3

    echo "${ERROR_TYPE} :: ${MESSAGE}"
    exit "${CUSTOM_EXIT_CODE}"
}

function startDockerComposeStack() {
    if docker compose version &>/dev/null; then
        echo "Using 'docker compose' v2"
        docker compose -f ./docker-compose.yml up -d
    elif docker-compose version &>/dev/null; then
        echo "Using 'docker-compose' v1"
        docker-compose -f ./docker-compose.yml up -d
    else
        echo "Docker compose seems not to be installed"
    fi
}

function checkInfluxDb() {
    for ((i = 1; i <= TRY_MAX; i++)); do
        echo -n "${i}/${TRY_MAX} $(date '+%F %T'):: "
        if curl -sLI --url localhost:8086/ping | grep -q "X-Influxdb-Version:"; then
            echo "SUCCESS"
            break
        else
            if [[ $TRY_MAX -eq 10 ]]; then
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
        RESPONSE=$(curl \
            --silent \
            --header 'Content-Type: application/json' \
            --header 'Accept: application/json' \
            --url 'http://adminuser:adminpassword@localhost:3000/api/search?dashboardIds' | jq -r '.[0].title')
        if [[ "${RESPONSE}" = "SpeedFlux" ]]; then
            echo "SUCCESS"
            break
        else
            if [[ $TRY_MAX -eq 10 ]]; then
                customExit "CRITICAL" "Grafana Dashboard seems not to be provisioned correctly." "255"
            else
                echo "Waiting for next run in 5 seconds..."
                sleep 5
            fi
        fi
    done
}

function stopDockerComposeStack() {
    if docker compose version &>/dev/null; then
        echo "Using 'docker compose' v2"
        docker compose -f ./docker-compose.yml kill
    elif docker-compose version &>/dev/null; then
        echo "Using 'docker-compose' v1"
        docker-compose -f ./docker-compose.yml kill
    else
        echo "Docker compose seems not to be installed"
    fi
}
