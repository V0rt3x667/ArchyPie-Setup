#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-mess"
rp_module_desc="MESS (Latest Version) Libretro Core"
rp_module_help="ROM Extension: .zip"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/mame/master/COPYING"
rp_module_repo="git https://github.com/libretro/mame master"
rp_module_section="exp"
rp_module_flags=""

function depends_lr-mess() {
    depends_lr-mame
}

function sources_lr-mess() {
    sources_lr-mame
}

function build_lr-mess() {
    # More Memory Is Required For 64bit Platforms
    if isPlatform "64bit"; then
        rpSwap on 8192
    else
        rpSwap on 4096
    fi

    local params=($(_get_params_lr-mame) 'SUBTARGET=mess')
    make clean
    make "${params[@]}"
    rpSwap off
    md_ret_require="${md_build}/mamemess_libretro.so"
}

function install_lr-mess() {
    md_ret_files=(
        'hash'
        'mamemess_libretro.so'
    )
}

function configure_lr-mess() {
    local core="${1}"
    [[ -z "${core}" ]] && core="mamemess_libretro.so"

    local systems=(
        'arcadia'
        'coleco'
        'crvision'
        'gb'
        'nes'
    )

    if [[ "${md_mode}" == "install" ]]; then
        for system in "${systems[@]}"; do
            mkRomDir "${system}"
            mkUserDir "${biosdir}/${system}"
            defaultRAConfig "${system}"

            # Create BIOS Directories For The MESS Cores
            local dir
            if [[ "${md_id}" == "lr-mess2016" ]]; then
                dir="mame2016"
            else
                dir="mame"
            fi

            [[ ! -d "${biosdir}/mame-libretro/${dir}" ]] && mkUserDir "${biosdir}/mame-libretro/${dir}"

            ln -snf "${biosdir}/mame-libretro/${dir}" "${biosdir}/${system}/${dir}"
        done

        # Copy 'hash' Directory To Shared 'mame-libretro' Directory
        cp -rv "${md_inst}/hash" "${biosdir}/mame-libretro/${dir}"
        chown -R "${user}:${user}" "${biosdir}/mame-libretro/${dir}"

        setRetroArchCoreOption "mame_softlists_enable" "enabled"
        setRetroArchCoreOption "mame_softlists_auto_media" "enabled"
        setRetroArchCoreOption "mame_boot_from_cli" "enabled"
    fi

    for system in "${systems[@]}"; do
        addEmulator 0 "${md_id}" "${system}" "${md_inst}/${core}"
        addSystem "${system}"
    done
}
