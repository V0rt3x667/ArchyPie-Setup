#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

__version="4.9.0_beta"

[[ "${__debug}" -eq 1 ]] && set -x

# ArchyPie Install Location
rootdir="/opt/archypie"

# Install For "__user" Else Use "SUDO_USER"
if [[ -n "${__user}" ]]; then
    user="${__user}"
    if ! id -u "${__user}" &>/dev/null; then
        echo "User ${__user} Does Not Exist!"
        exit 1
    fi
else
    user="${SUDO_USER}"
    [[ -z "${user}" ]] && user="$(id -un)"
fi

home="$(eval echo ~"${user}")"
datadir="${home}/ArchyPie"
biosdir="${datadir}/BIOS"
romdir="${datadir}/roms"
arpdir="${datadir}/configs"
emudir="${rootdir}/emulators"
configdir="${rootdir}/configs"

scriptdir="$(dirname "$0")"
scriptdir="$(cd "${scriptdir}" && pwd)"

__logdir="${scriptdir}/logs"
__tmpdir="${scriptdir}/tmp"
__builddir="${__tmpdir}/build"
__swapdir="${__tmpdir}"

# Launch Script
launch_dir=$(dirname archypie_packages)
launch_dir="$(pwd)"
if [[ "$(id -u)" -ne 0 ]]; then
    display="${XDG_SESSION_TYPE}"
    sudo __XDG_SESSION_TYPE="${display}" "${launch_dir}/archypie_packages.sh" "$@"
    exit $?
fi

__backtitle="ArchyPie Setup - Installation Folder: ${rootdir} User: ${user}"

source "${scriptdir}/scriptmodules/system.sh"
source "${scriptdir}/scriptmodules/helpers.sh"
source "${scriptdir}/scriptmodules/inifuncs.sh"
source "${scriptdir}/scriptmodules/packages.sh"

setup_env

rp_registerAllModules

rp_ret=0
if [[ "$#" -gt 0 ]]; then
    setupDirectories
    rp_callModule "$@"
    rp_ret="$?"
else
    rp_printUsageinfo
fi

if [[ "${#__ERRMSGS[@]}" -gt 0 ]]; then
    # Override Return Code If ERRMSGS Is Set
    [[ "$rp_ret" -eq 0 ]] && rp_ret=1
    printMsgs "console" "Errors:\n" "${__ERRMSGS[@]}"
fi

if [[ "${#__INFMSGS[@]}" -gt 0 ]]; then
    printMsgs "console" "Info:\n" "${__INFMSGS[@]}"
fi

exit ${rp_ret}
