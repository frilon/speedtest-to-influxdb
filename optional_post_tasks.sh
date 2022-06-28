#! /usr/bin/env bash

# shellcheck source=.env
source .env

# Grafana website protocol. One of: 'http' or 'https'
# Default: http
GF_PROTOCOL="http"
# Grafana's used ip address or domain
# Default: localhost
GF_BASE_URL="localhost"
# Grafana's used port
# Default: 3000
GF_PORT=3000
# Grafana's used theme. One of: light, dark, or an empty string for the default theme
# Default: ""
GF_THEME="dark"
# Grafana's used timezone. One of: utc, browser, or an empty string for the default
# Default: ""
GF_TIMEZONE="browser"
# Grafana's used week start. One of: saturday, sunday, monday or an empty string for the default
# Default: ""
GF_WEEKSTART="monday"

GF_API_URL="${GF_PROTOCOL}://${GF_SECURITY_ADMIN_USER}:${GF_SECURITY_ADMIN_PASSWORD}@${GF_BASE_URL}:${GF_PORT}"

function setSpeedfluxDashboardAsHome() {
    curl \
        --silent \
        --header 'Content-Type: application/json' \
        --header 'Accept: application/json' \
        --request 'POST' \
        --url "${GF_API_URL}/api/user/stars/dashboard/1" | jq -r '.message'

    curl \
        --silent \
        --header 'Content-Type: application/json' \
        --header 'Accept: application/json' \
        --request 'PATCH' \
        --url "${GF_API_URL}/api/user/preferences" \
        --data-raw '{"homeDashboardUID": "aO0vhU3nk"}' | jq -r '.message'
}

function updateUsersTheme() {
    curl \
        --silent \
        --header 'Content-Type: application/json' \
        --header 'Accept: application/json' \
        --request 'PATCH' \
        --url "${GF_API_URL}/api/user/preferences" \
        --data-raw '{"theme": "'"${GF_THEME}"'"}' | jq -r '.message'
}
function updateUsersTimezone() {
    curl \
        --silent \
        --header 'Content-Type: application/json' \
        --header 'Accept: application/json' \
        --request 'PATCH' \
        --url "${GF_API_URL}/api/user/preferences" \
        --data-raw '{"timezone": "'"${GF_TIMEZONE}"'"}' | jq -r '.message'
}
function updateUsersWeekstart() {
    curl \
        --silent \
        --header 'Content-Type: application/json' \
        --header 'Accept: application/json' \
        --request 'PATCH' \
        --url "${GF_API_URL}/api/user/preferences" \
        --data-raw '{"weekStart": "'"${GF_WEEKSTART}"'"}' | jq -r '.message'
}

function showHelp() {
    echo ""
    echo "Usage: bash ${0} [--all]|[[--home-dashboard][--theme][--timezone][--weekstart]]"
    echo ""
}

function main() {
    if [[ ${#} -eq 0 ]]; then
        showHelp
        exit 1
    fi

    while (($#)); do
        case "${1}" in
        --home-dashboard)
            setSpeedfluxDashboardAsHome
            ;;
        --theme)
            updateUsersTheme
            ;;
        --timezone)
            updateUsersTimezone
            ;;
        --weekstart)
            updateUsersWeekstart
            ;;
        --all)
            setSpeedfluxDashboardAsHome
            updateUsersTheme
            updateUsersTimezone
            updateUsersWeekstart
            ;;
        *)
            showHelp
            ;;
        esac
        shift
    done

}

main "$@"
