#!/bin/bash

set -ex


### Setup
SERVICES=(moonraker klipper nginx)


### Get User
function get_user_name {
    DEFAULT_USER="$(grep "1000" /etc/passwd | awk -F ':' '{print $1}')"
    export DEFAULT_USER
}

### Stop services first
function stop_services {
    for srv in "${SERVICES[@]}"; do
        sudo systemctl stop "${srv}.service"
    done
}

function start_services {
    for srv in "${SERVICES[@]}"; do
        sudo systemctl start "${srv}.service"
    done
}

function reload_daemons {
    sudo systemctl daemon-reload
}

### Change nginx root
function change_www_root {
    sudo bash -c "
        sed -i 's|/home/pi/mainsail|/home/${DEFAULT_USER}/mainsail|g' \
        /etc/nginx/sites-available/mainsail
    "
}








### Main
get_user_name
stop_services
change_www_root
reload_daemons
start_services
