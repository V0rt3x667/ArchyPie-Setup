#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="xpadneo"
rp_module_desc="xpadneo - Advanced Linux Driver for Xbox One Wireless Gamepads"
rp_module_licence="GPL3 https://raw.githubusercontent.com/atar-axis/xpadneo/master/LICENSE"
rp_module_repo="git https://github.com/atar-axis/xpadneo.git v0.9.3"
rp_module_section="driver"
rp_module_flags="nobin"

function _version_xpadneo() {
    cat "$md_inst/VERSION"
}

function depends_xpadneo() {
    local depends=(dkms rsync linux-headers dkms bluez bluez-utils)
    getDepends "${depends[@]}"
}

function sources_xpadneo() {
    gitPullOrClone
    rsync -a --delete "$md_build/hid-xpadneo/" "$md_inst/"
    cp "$md_build/VERSION" "$md_inst/"
    local version="$(_version_xpadneo)"
    sed "s/@DO_NOT_CHANGE@/$version/g" "$md_inst/dkms.conf.in" > "$md_inst/dkms.conf"
}

function build_xpadneo() {
    dkmsManager install hid-xpadneo "$(_version_xpadneo)"
}

function remove_xpadneo() {
    dkmsManager remove hid-xpadneo "$(_version_xpadneo)"
}

function configure_xpadneo() {
    [[ "$md_mode" == "remove" ]] && return

    dkmsManager reload hid-xpadneo "$(_version_xpadneo)"
}
