#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-fuse"
rp_module_desc="Sinclair ZX Spectrum Libretro Core"
rp_module_help="ROM Extensions: .dsk .rzx .scl .tap .trd .tzx .z80 .zip\n\nCopy ZX Spectrum Games To: ${romdir}/zxspectrum"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/fuse-libretro/master/LICENSE"
rp_module_repo="git https://github.com/libretro/fuse-libretro master"
rp_module_section="main"

function sources_lr-fuse() {
    gitPullOrClone
}

function build_lr-fuse() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro

    md_ret_require="${md_build}/fuse_libretro.so"
}

function install_lr-fuse() {
    md_ret_files=('fuse_libretro.so')
}

function configure_lr-fuse() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "zxspectrum"
        defaultRAConfig "zxspectrum"

        # Default To 128k Spectrum
        setRetroArchCoreOption "fuse_machine" "Spectrum 128K"
    fi

    addEmulator 1 "${md_id}" "zxspectrum" "${md_inst}/fuse_libretro.so"

    addSystem "zxspectrum"
}
