#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="redream"
rp_module_desc="Redream: Sega Dreamcast Emulator"
rp_module_help="ROM Extensions: .cdi .chd .cue .gdi .iso\n\nCopy Dreamcast ROMs To: ${romdir}/dreamcast"
rp_module_licence="PROP"
rp_module_section="exp"
rp_module_flags="noinstclean !all !wayland gles31 aarch64 x86_64"

function __binary_url_redream() {
    local platf="universal-raspberry"
    isPlatform "x86_64" && platf="x86_64"
    local url="https://${md_id}.io/download/${md_id}.${platf}-linux-latest.tar.gz"

    echo "${url}"
}

function install_bin_redream() {
    downloadAndExtract "$(__binary_url_redream)" "${md_inst}"
}

function configure_redream() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "dreamcast"

        local dest="${md_conf_root}/dreamcast/${md_id}"
        mkUserDir "${dest}"

        # Symlinks Configs & Cache
        moveConfigFile "${md_inst}/${md_id}.cfg" "${dest}/${md_id}.cfg"
        moveConfigDir "${md_inst}/cache" "${dest}/cache"
        moveConfigDir "${md_inst}/saves" "${dest}/saves"
        moveConfigDir "${md_inst}/states" "${dest}/states"
        chown -R "${user}:${user}" "${md_inst}"

        # Symlink Memory Cards
        local i
        for i in 0 1 2 3; do
            moveConfigFile "${md_inst}/vmu$i.bin" "${dest}/vmu$i.bin"
        done

        # Symlink BIOS Files
        mkUserDir "${biosdir}/dreamcast"
        ln -sf "${biosdir}/dreamcast/dc_boot.bin" "${md_inst}/boot.bin"
        ln -sf "${biosdir}/dreamcast/dc_flash.bin" "${md_inst}/flash.bin"
    fi

    addEmulator 1 "${md_id}" "dreamcast" "${md_inst}/${md_id} %ROM%"

    addSystem "dreamcast"
}
