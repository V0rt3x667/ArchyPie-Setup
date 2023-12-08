#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-neocd"
rp_module_desc="Neo Geo CD Libretro Core"
rp_module_help="ROM Extension: .chd .cue\n\nCopy Neo Geo CD ROMs To:\n${romdir}/neocd\n\nCopy One Of The Following BIOS Files: front-sp1.bin, neocd_f.rom, neocd_sf.rom, neocd_st.rom, neocd_sz.rom, neocd_t.rom, neocd_z.rom, neocd.bin, top-sp1.bin, uni-bioscd.rom To: ${biosdir}/neocd"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/neocd_libretro/master/LICENSE.md"
rp_module_repo="git https://github.com/libretro/neocd_libretro master"
rp_module_section="exp"

function sources_lr-neocd() {
    gitPullOrClone

    # Fix BIOS Path
    sed "/strlcat(buffer, NEOCD_SYSTEM_SUBDIR, len);/d" -i "${md_build}/src/path.cpp"
}

function build_lr-neocd() {
    make clean
    make
    md_ret_require="${md_build}/neocd_libretro.so"
}

function install_lr-neocd() {
    md_ret_files=('neocd_libretro.so')
}

function configure_lr-neocd() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "neocd"
        mkUserDir "${biosdir}/neocd"
        defaultRAConfig "neocd"
    fi

    addEmulator 1 "${md_id}" "neocd" "${md_inst}/neocd_libretro.so"

    addSystem "neocd"
}
