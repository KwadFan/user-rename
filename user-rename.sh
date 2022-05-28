#!/bin/bash

set -ex


### Get User


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
        sed -i 's|/home/pi/mainsail|/home/${USER}/mainsail|g' \
        /etc/nginx/sites-available/mainsail
    "
}








### Main
stop_services
change_www_root




### Restart services

# for srv in "${SERVICES[@]}"; do
#     sudo systemctl stop "${srv}.service"
# done

# Restart only nginx for now
sudo systemctl start nginx.service
