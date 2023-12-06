#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-hatari"
rp_module_desc="Atari ST, STE, TT & Falcon Libretro Core"
rp_module_help="ROM Extensions: .dim .ipf .m3u .msa .st .stx .zip\n\nCopy Atari ST Games To: ${romdir}/atarist\n\nCopy Atari ST BIOS File: tos.img To: ${biosdir}/atarist"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/hatari/master/gpl.txt"
rp_module_repo="git https://github.com/libretro/hatari master"
rp_module_section="exp"

function depends_lr-hatari() {
    getDepends zlib
}

function sources_lr-hatari() {
    gitPullOrClone

    # Add CapsImg Support
    applyPatch "${md_data}/01_add_capsimage.patch"

    # Set Default Config Path(s)
    sed -e "s|#define HATARI_HOME_DIR \".hatari\"|#define HATARI_HOME_DIR \"ArchyPie/configs/${md_id}\"|g" -i "${md_build}/src/paths.c"

    _sources_capsimage_hatari
}

function build_lr-hatari() {
    _build_capsimage_hatari

    cd "${md_build}" || exit
    make -f Makefile.libretro clean
    CFLAGS+=" -D__cdecl='' -I\"${md_build}/src/includes/caps\" -DHAVE_CAPSIMAGE=1 -DCAPSIMAGE_VERSION=5" \
    CAPSIMG_LDFLAGS="-L./lib -l:libcapsimage.so.5" \
    make -f Makefile.libretro

    md_ret_require="${md_build}/hatari_libretro.so"
}

function install_lr-hatari() {
    # Install: CapsImg Library
    mkdir "${md_inst}/lib"
    cp -Pv "${md_build}/lib"/*.so* "${md_inst}/lib/"

    md_ret_files=('hatari_libretro.so')
}

function configure_lr-hatari() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/atarist/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "atarist"
        mkUserDir "${biosdir}/atarist"
        defaultRAConfig "atarist"
    fi

    addEmulator 1 "${md_id}" "atarist" "${md_inst}/hatari_libretro.so"

    addSystem "atarist"

    # Add LD_LIBRARY_PATH='${md_inst}/lib' To Start Of Launch Command
    iniConfig " = " '"' "${configdir}/atarist/emulators.cfg"
    iniGet "${md_id}"
    iniSet "${md_id}" "LD_LIBRARY_PATH='${md_inst}/lib' ${ini_value}"
}
