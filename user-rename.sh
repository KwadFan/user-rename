#!/bin/bash

set -ex


### Setup
SERVICES=(moonraker klipper nginx sonar webcamd)
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

function relocate_venv {
    local -a venvs
    venvs=(klippy-env moonraker-env)

    for venv in "${venvs[@]}"; do
        sudo -u "${DEFAULT_USER}" \
        virtualenv --relocatable "${HOME}/${venv}"
    done
}

function reinstall_polkit_rules {
    pushd /home/"${DEFAULT_USER}"/moonraker &> /dev/null || exit 1
        ## Install rules
        ./scripts/set-policykit-rules.sh
    popd &> /dev/null || exit 1
}

## Fix broken links
function fix_broken_links {
    local -a brokenlinks
    local path
    brokenlinks=(webcamd sonar)
    path="/usr/local/bin"

    for bl in "${brokenlinks[@]}"; do
        if [ -h "${path}/${bl}" ]; then
            sudo rm -rf "${path}/${bl}"
        fi
        find "/home/${DEFAULT_USER}" -type f -iname "${bl}" -print0 | \
        xargs -0 -i sudo ln -s {} "${path}/${bl}"
    done
}


### Main
get_user_name
stop_services
change_www_root
change_service_user
relocate_venv
reinstall_polkit_rules
fix_broken_links
sleep 2
sudo systemctl daemon-reload
start_services
sleep 2
sudo reboot

