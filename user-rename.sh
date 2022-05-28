#!/bin/bash

set -ex


### Setup
SERVICES=(moonraker klipper nginx)
SYSTEMD_DIR="/etc/systemd/system"


### Get User
function get_user_name {
    DEFAULT_USER="$(grep "1000" /etc/passwd | awk -F ':' '{print $1}')"
    export DEFAULT_USER
}

### Mangle services
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

### Change nginx root
function change_www_root {
    sudo bash -c "
        sed -i 's|/home/pi/mainsail|/home/${DEFAULT_USER}/mainsail|g' \
        /etc/nginx/sites-available/mainsail
    "
}


### change username in service files
function change_service_user {
    ### Filter nginx service first!
    local -a servicefile
    servicefile=( "${SERVICES[@]/nginx}" )

    for i in "${servicefile[@]}"; do
        if [ -n "${i}" ]; then
        sudo -E sed -i 's/pi/'"${DEFAULT_USER}"'/g' "${SYSTEMD_DIR}/${i}.service"
        fi
    done
}







### Main
get_user_name
stop_services
change_www_root
change_service_user
sudo systemctl daemon-reload
start_services
