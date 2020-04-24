#!/bin/bash
set -e

workspace_path="/var/www"

main()
{
    process_file_perms

    # cd "${workspace_path}"
    # npm install

    info "Finally running the supervisord" 1
    supervisord -c /etc/supervisord.conf
}

process_dir()
{
    dir="$1"
    info "Processing directory ${dir}"
    mkdir -p "${dir}"
    chmod 777 "${dir}"
    chown www-data:www-data "${dir}"
    chgrp www-data "${dir}"
}

process_file_perms()
{
    info "Fixing permissions for certain files"
    find "${workspace_path}" -type d -exec chown www-data:www-data {} \;  # Change directory owner
    find "${workspace_path}" -type f -exec chown www-data:www-data {} \;  # Change files owner
    find "${workspace_path}" -type d -exec chmod 777 {} \;  # Change directory permissions rwxr-xr-x
    find "${workspace_path}" -type f -exec chmod 777 {} \;  # Change file permissions rw-r--r--
    info "Fixed all the permissions for all the files"
}

info()
{
    message="$1"
    blink=''
    [ -z "$2" ] || blink=';5'

    echo -e "\e[45;1${blink}m$message\e[0m"
}

main $*