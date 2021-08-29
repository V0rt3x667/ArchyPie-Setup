#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="steamlink"
rp_module_desc="Steam Link for Raspberry Pi 3 or Later"
rp_module_licence="PROP https://steamcommunity.com/app/353380/discussions/0/1743353164093954254/"
rp_module_section="exp"
rp_module_flags="!all rpi3 rpi4"
rp_module_help="Stream Games from your Computer with Steam"

function depends_steamlink() {
    getDepends python libinput libxkbcommon xorg-server zenity && pacmanPkg archy-matchbox-window-manager
}

function install_bin_steamlink() {
    pacmanInstall archy-steamlink
}

function remove_steamlink() {
    pacmanRemove archy-steamlink
}

function configure_steamlink() {
    local sl_script="$md_inst/steamlink_xinit.sh"
    local sl_dir="$home/.local/share/SteamLink"
    local valve_dir="$home/.local/share/Valve Corporation"

    if [[ "$md_mode" == "install" ]]; then
        mkUserDir "$sl_dir"
        mkUserDir "$valve_dir"
        mkUserDir "$valve_dir/SteamLink"
        mkUserDir "$md_conf_root/$md_id"

        # create optional streaming_args.txt for user modification
        touch "$valve_dir/SteamLink/streaming_args.txt"
        chown $user:$user "$valve_dir/SteamLink/streaming_args.txt"
        moveConfigFile "$valve_dir/SteamLink/streaming_args.txt" "$md_conf_root/$md_id/streaming_args.txt"

        cat > "$sl_script" << _EOF_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager &
/usr/bin/steamlink
_EOF_
        chmod +x "$sl_script"
    fi

    addPort "$md_id" "steamlink" "Steam Link" "XINIT:$sl_script"
}
