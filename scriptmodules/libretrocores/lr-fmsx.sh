#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-fmsx"
rp_module_desc="Microsoft MSX, MSX2 & MSX2+ Libretro Core"
rp_module_help="ROM Extensions: .cas .dsk .fdi .m3u .mx1 .mx2 .rom .zip\n\nCopy MSX Games To: ${romdir}/msx\nCopy MSX2 Games To: ${romdir}/msx2\nCopy Colecovision Games To: ${romdir}/coleco\n\nCopy BIOS Files (DISK.ROM, MSX.ROM, MSX2.ROM, MSX2EXT.ROM, MSX2P.ROM, MSX2PEXT.ROM) To: ${biosdir}/msx"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/fmsx-libretro/master/LICENSE"
rp_module_repo="git https://github.com/libretro/fmsx-libretro master"
rp_module_section="opt"

function sources_lr-fmsx() {
    gitPullOrClone
}

function build_lr-fmsx() {
    make clean
    make
    md_ret_require="${md_build}/fmsx_libretro.so"
}

function install_lr-fmsx() {
    md_ret_files=(
        'fmsx_libretro.so'
        'fMSX/ROMs/CARTS.SHA'
        'README.md'
    )
}

function configure_lr-fmsx() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "msx"
        mkRomDir "msx2"

        mkUserDir "${biosdir}/msx"

        # Copy CARTS.SHA To '${biosdir}'
        cp "${md_inst}/CARTS.SHA" "${biosdir}/msx"
        chown "${user}:${user}" "${biosdir}/msx/CARTS.SHA"
    fi

    defaultRAConfig "msx" "system_directory" "${biosdir}/msx"
    defaultRAConfig "msx2" "system_directory" "${biosdir}/msx"

    # Default To MSX2+ Core
    setRetroArchCoreOption "fmsx_mode" "MSX2+"

    addEmulator 0 "${md_id}" "msx" "${md_inst}/fmsx_libretro.so"
    addEmulator 0 "${md_id}" "msx2" "${md_inst}/fmsx_libretro.so"

    addSystem "msx"
    addSystem "msx2"
}
