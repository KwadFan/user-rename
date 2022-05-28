#!/bin/bash

set -ex


### Get User
function get_user_name {
    DEFAULT_USER="$(grep "1000" /etc/passwd | awk '{print $1}')"
    export DEFAULT_USER
}

### Stop services first
function stop_services {
    local -a services
    services=(moonraker klipper nginx)
    for srv in "${services[@]}"; do
        sudo systemctl stop "${srv}.service"
    done
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




### Restart services

# for srv in "${SERVICES[@]}"; do
#     sudo systemctl stop "${srv}.service"
# done

# Restart only nginx for now
sudo systemctl start nginx.service
