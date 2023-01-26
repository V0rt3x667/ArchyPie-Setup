#!/usr/bin/bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

function check_sudo() {
    if [[ "$(id -u)" -ne 0 ]]; then
        return
    else
        echo "The script must be run as './archypie-setup' and not 'sudo ./archypie-setup'. You will still be prompted to enter your sudo password."
        echo "This change is required so that the environment variable 'XDG_SESSION_TYPE' can be passed to the script. Thank you."
        exit 1
    fi
}

check_sudo

scriptdir="$(dirname "$0")"
scriptdir="$(cd "${scriptdir}" && pwd)"

display="${XDG_SESSION_TYPE}"
sudo __XDG_SESSION_TYPE="${display}" "${scriptdir}/archypie_packages.sh" setup gui
