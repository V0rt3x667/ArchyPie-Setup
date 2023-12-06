#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-gambatte"
rp_module_desc="Nintendo Gameboy & GameBoy Color Libretro Core"
rp_module_help="ROM Extensions: .dmg .gb .gbc .zip\n\nCopy GameBoy ROMs To: ${romdir}/gb\n\nCopy GameBoy Color ROMs To: ${romdir}/gbc\n\nOPTIONAL:\nCopy BIOS File: gb_bios.bin To: ${biosdir}/gb\nCopy BIOS File: gbc_bios.bin To: ${biosdir}/gbc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/gambatte-libretro/master/COPYING"
rp_module_repo="git https://github.com/libretro/gambatte-libretro master"
rp_module_section="main"

function sources_lr-gambatte() {
    gitPullOrClone
}

function build_lr-gambatte() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    md_ret_require="${md_build}/gambatte_libretro.so"
}

function install_lr-gambatte() {
    md_ret_files=('gambatte_libretro.so')
}

function configure_lr-gambatte() {
    local systems=(
        'gb'
        'gbc'
    )

    if [[ "${md_mode}" == "install" ]]; then
        for system in "${systems[@]}"; do
            mkRomDir "${system}"
            mkUserDir "${biosdir}/${system}"
            defaultRAConfig "${system}"
        done

        # Add Default Green Yellow Palette For Gameboy Classic
        mkUserDir "${biosdir}/gb/palettes"
        cp "${md_data}/default.pal" "${biosdir}/gb/palettes/"
        chown "${user}:${user}" "${biosdir}/gb/palettes/default.pal"

        setRetroArchCoreOption "gambatte_gb_colorization" "custom"
    fi

    for system in "${systems[@]}"; do
        addEmulator 1 "${md_id}" "${system}" "${md_inst}/gambatte_libretro.so"
        addSystem "${system}"
    done
}
