#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-puae2021"
rp_module_desc="Commodore Amiga 500, 500+, 600, 1200, 4000, CDTV & CD32 Libretro Core (v2.6.1)"
rp_module_help="ROM Extensions: .7z .adf .adz .ccd .chd .cue .dms .fdi .hdf .hdz .info .ipf .iso .lha .m3u .mds .nrg .slave .uae .zip\n\nCopy Amiga Games To: ${romdir}/amiga\nCopy CD32 Games To: ${romdir}/amigacd32\nCopy CDTV Games To: ${romdir}/amigacdtv\n\nCopy BIOS Files:\n\nkick34005.A500\nkick40063.A600\nkick40068.A1200\nkick40060.CD32\nkick34005.CDTV\n\nTo: ${biosdir}/amiga"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/PUAE/master/COPYING"
rp_module_repo="git https://github.com/libretro/libretro-uae 2.6.1"
rp_module_section="opt"

function sources_lr-puae2021() {
    gitPullOrClone

    _sources_capsimg
}

function build_lr-puae2021() {
    _build_capsimg

    cd "${md_build}" || exit
    make clean
    make
    md_ret_require="${md_build}/puae2021_libretro.so"
}

function install_lr-puae2021() {
    md_ret_files=(
        'puae2021_libretro.so'
        'sources/uae_data'
    )
    if [[ ! -f "${biosdir}amiga/capsimg.so" ]]; then
        cp "${md_build}/capsimg/Linux/x86-64/capsimg.so" "${biosdir}/amiga"
    fi
}

function configure_lr-puae2021() {
    local systems=(
        'amiga'
        'amigacd32'
        'amigacdtv'
    )

    if [[ "${md_mode}" == "install" ]]; then
        for system in "${systems[@]}"; do
            mkRomDir "${system}"
        done

        mkUserDir "${biosdir}/amiga"
        mkUserDir "${md_conf_root}/amigacdtv"

        # Force CDTV System
        local config="${md_conf_root}/amigacdtv/retroarch-core-options.cfg"
        iniConfig " = " '"' "${config}"
        iniSet "puae_model" "CDTV" "${config}"
        chown "${user}:${user}" "${config}"
    fi

    defaultRAConfig "${system}" "system_directory" "${biosdir}/amiga"

    for system in "${systems[@]}"; do
        addEmulator 0 "${md_id}" "${system}" "${md_inst}/puae2021_libretro.so"
        addSystem "${system}"
    done

    # Add CDTV Overide To 'retroarch.cfg', 'defaultRAConfig' Can Only Be Called Once
    local raconfig="${md_conf_root}/amigacdtv/retroarch.cfg"
    iniConfig " = " '"' "${raconfig}"
    iniSet "core_options_path" "${config}"
    chown "${user}:${user}" "${raconfig}"
}
