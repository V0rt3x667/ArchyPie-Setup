#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="minecraft"
rp_module_desc="Minecraft - Pi Edition"
rp_module_licence="PROP"
rp_module_repo="file https://s3.amazonaws.com/assets.minecraft.net/pi/minecraft-pi-0.1.1.tar.gz"
rp_module_section="exp"
rp_module_flags="!all videocore"

function depends_minecraft() {
    getDepends xorg-server && pacmanPkg archy-matchbox-window-manager
}

function install_bin_minecraft() {
    [[ -f "$md_inst/minecraft-pi" ]] && rm -rf "$md_inst/"*
    downloadAndExtract "$rp_repo_url" "$md_build" --strip-components 1
}

function remove_minecraft() {
    rm -rf "$md_inst/minecraft-pi" && pacmanRemove archy-matchbox-window-manager
}

function configure_minecraft() {
    addPort "$md_id" "minecraft" "Minecraft" "XINIT:$md_inst/Minecraft.sh"

    cat >"$md_inst/Minecraft.sh" << _EOF_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager &
/usr/bin/minecraft-pi
_EOF_
    chmod +x "$md_inst/Minecraft.sh"
}
