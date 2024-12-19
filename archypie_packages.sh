#!/bin/bash

################################################################################
# This file is part of the ArchyPie Project                                    #
#                                                                              #
# Please see the LICENSE file at the top-level directory of this distribution. #
################################################################################

__version="1.0.0_new-beta"

[[ "${__debug}" -eq 1 ]] && set -x

# ArchyPie install location
rootdir="/opt/archypie"

# If no user is specified
if [[ -z "${__user}" ]]; then
    # Get the calling user from sudo env
    __user="${SUDO_USER}"
    # If not called from sudo get the current user
    [[ -z "${__user}" ]] && __user="$(id -un)"
fi

# Check if the user exists
if [[ -z "$(getent passwd "${__user}")" ]]; then
    echo "User ${__user} does not exist."
    exit 1
fi

# If no group is specified get the users primary group
if [[ -z "${__group}" ]]; then
    __group="$(id -gn "${__user}")"
fi

# Check if the group exists
if [[ -z "$(getent group "${__group}")" ]]; then
    echo "Group ${__group} does not exist!"
    exit 1
fi

# Backwards compatibility
#user="${__user}"

home="$(eval echo ~${__user})"
datadir="${home}/ArchyPie"
#arpdir="${datadir}/configs"
biosdir="${datadir}/bios"
romdir="${datadir}/roms"
savedir="${datadir}/saves"

configdir="${rootdir}/configs"
emudir="${rootdir}/emulators"

scriptdir="$(dirname "${0}")"
scriptdir="$(cd "${scriptdir}" && pwd)"

__logdir="${scriptdir}/logs"
__tmpdir="${scriptdir}/tmp"
__builddir="${__tmpdir}/build"
__swapdir="${__tmpdir}"

# Check if sudo is used
if [[ "$(id -u)" -ne 0 ]]; then
    echo "The ArchyPie setup script must be run under sudo from the user you want to install for. Try 'sudo ${0}'"
    exit 1
fi

__backtitle="ArchyPie Setup - Installation folder: ${rootdir} for user ${__user}"

source "${scriptdir}/scriptmodules/system.sh"
source "${scriptdir}/scriptmodules/helpers.sh"
source "${scriptdir}/scriptmodules/inifuncs.sh"
source "${scriptdir}/scriptmodules/packages.sh"

setup_env

rp_registerAllModules

ensureFBMode 320 240

rp_ret=0
if [[ "${#}" -gt 0 ]]; then
    setupDirectories
    rp_callModule "${@}"
    rp_ret="${?}"
else
    rp_printUsageinfo
fi

if [[ "${#__ERRMSGS[@]}" -gt 0 ]]; then
    # Override return code if ERRMSGS is set - eg in the case of calling basic_install from setup
    # we won't get the return code, as we don't handle return codes when calling non packaging functions
    # as it would require all modules functions to handle errors differently, and make things more complicated
    [[ "${rp_ret}" -eq 0 ]] && rp_ret=1
    printMsgs "console" "Errors:\n${__ERRMSGS[@]}"
fi

if [[ "${#__INFMSGS[@]}" -gt 0 ]]; then
    printMsgs "console" "Info:\n${__INFMSGS[@]}"
fi

exit ${rp_ret}
