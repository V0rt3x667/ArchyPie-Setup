#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-mame2003-plus"
rp_module_desc="MAME 0.78 Enhanced Libretro Core"
rp_module_help="ROM Extension: .zip\n\nCopy MAME ROMs To Either:\n${romdir}/mame-libretro\n${romdir}/arcade"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/mame2003-plus-libretro/master/LICENSE.md"
rp_module_repo="git https://github.com/libretro/mame2003-plus-libretro master"
rp_module_section="opt"

function sources_lr-mame2003-plus() {
    gitPullOrClone
}

function build_lr-mame2003-plus() {
    rpSwap on 750
    local params=()
    isPlatform "arm" && params+=("ARM=1")
    make clean
    make ARCH="${CFLAGS}" "${params[@]}"
    rpSwap off
    md_ret_require="${md_build}/mame2003_plus_libretro.so"
}

function install_lr-mame2003-plus() {
    md_ret_files=(
        'mame2003_plus_libretro.so'
        'metadata'
    )
}

function configure_lr-mame2003-plus() {
    local systems=(
        'arcade'
        'mame-libretro'
        'neogeo'
        'segastv'
    )

    if [[ "${md_mode}" == "install" ]]; then
        local core_name="mame2003-plus"

        for system in "${systems[@]}"; do
            mkRomDir "${system}"
            mkUserDir "${biosdir}/${system}"
            defaultRAConfig "${system}"

            [[ ! -d "${biosdir}/mame-libretro/${core_name}" ]] && mkUserDir "${biosdir}/mame-libretro/${core_name}"

            if [[ "${system}" != "mame-libretro" ]]; then
                ln -snf "${biosdir}/mame-libretro/${core_name}" "${biosdir}/${system}/${core_name}"
            fi
        done

        # Copy 'hiscore.dat', 'cheat.dat' & 'artwork'
        mkUserDir "${biosdir}/mame-libretro/${core_name}/"{artwork,samples}
        cp -rv "${md_inst}/metadata/"{cheat.dat,hiscore.dat} "${biosdir}/mame-libretro/${core_name}/"
        cp -v "${md_inst}/metadata/artwork/"* "${biosdir}/mame-libretro/${core_name}/artwork/"
        chown -R "${__user}":"${__group}" "${biosdir}/mame-libretro/${core_name}"

        setRetroArchCoreOption "${core_name}_skip_disclaimer" "enabled"
    fi

    for system in "${systems[@]}"; do
        local def=0
        if [[ "${system}" == "mame-libretro" ]]; then
            def=1
        fi
        addEmulator "${def}" "${md_id}" "${system}" "${md_inst}/mame2003_plus_libretro.so"
        addSystem "${system}"
    done
}
