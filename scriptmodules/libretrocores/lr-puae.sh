#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-puae"
rp_module_desc="Commodore Amiga 500, 500+, 600, 1200, 4000, CDTV & CD32 Libretro Core"
rp_module_help="ROM Extensions: .7z .adf .adz .ccd .chd .cue .dms .fdi .hdf .hdz .info .ipf .iso .lha .m3u .mds .nrg .slave .uae .zip\n\nCopy Amiga Games To: ${romdir}/amiga\nCopy CD32 Games To: ${romdir}/amigacd32\nCopy CDTV Games To: ${romdir}/amigacdtv\n\nCopy BIOS Files: kick34005.A500, kick40063.A600, kick40068.A1200, kick40060.CD32 & kick34005.CDTV To: ${biosdir}/amiga"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/PUAE/master/COPYING"
rp_module_repo="git https://github.com/libretro/libretro-uae master"
rp_module_section="opt"

function sources_lr-puae() {
    gitPullOrClone

    # Download the CAPSImg library used by FS-UAE
    local url
    url="https://fs-uae.net/files/CAPSImg/Stable/5.1.3/CAPSImg_5.1.3_Linux_x86-64.tar.xz"

    downloadAndExtract "${url}" "${md_build}/capsimg" --strip-components 1
}

function build_lr-puae() {
    make clean
    make
    md_ret_require="${md_build}/puae_libretro.so"
}

function install_lr-puae() {
    md_ret_files=(
        'capsimg/Linux/x86-64/capsimg.so'
        'puae_libretro.so'
        'sources/uae_data'
    )
}

function configure_lr-puae() {
    local core="${1}"
    [[ -z "${core}" ]] && core="puae_libretro.so"

    local systems=(
        'amiga'
        'amigacd32'
        'amigacdtv'
    )

    if [[ "${md_mode}" == "install" ]]; then
        for system in "${systems[@]}"; do
            mkRomDir "${system}"

            # Force CDTV System
            local config="${md_conf_root}/${system}/retroarch-core-options.cfg"
            if [[ "${system}" == "amigacdtv" ]]; then
                defaultRAConfig  "${system}" "core_options_path" "${config}"
                iniConfig " = " '"' "${config}"
                iniSet "puae_model" "CDTV" "${config}"
                chown "${__user}":"${__group}" "${config}"
            else
                defaultRAConfig "${system}"
            fi

            # Symlink Supported Systems' BIOS Directories To 'amiga'
            [[ ! -d "${biosdir}/amiga" ]] && mkUserDir "${biosdir}/amiga"
            if [[ "${system}" != "amiga" ]]; then
                ln -snf "${biosdir}/amiga" "${biosdir}/${system}"
            fi
        done

        # Copy CAPs Image & Floppy Disk Audio Files To BIOS Directory
        install -Dm644 "${md_inst}/capsimg.so" -t "${biosdir}/amiga/"
        cp -r "${md_inst}/uae_data" -t "${biosdir}/amiga/"
        chown -R "${__user}":"${__group}" "${biosdir}/amiga"
    fi

    for system in "${systems[@]}"; do
        addEmulator 1 "${md_id}" "${system}" "${md_inst}/${core}"
        addSystem "${system}"
    done
}
