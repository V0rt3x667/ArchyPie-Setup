#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="hatari"
rp_module_desc="Hatari: Atari ST, STE, TT & Falcon Emulator"
rp_module_help="ROM Extensions: .ctr .img .ipf .raw .rom .st .stx .zip\n\nCopy Atari ST Games To: ${romdir}/atarist\n\nCopy Atari ST BIOS File (tos.img) To: ${biosdir}"
rp_module_licence="GPL2 https://git.tuxfamily.org/hatari/hatari.git/plain/gpl.txt"
rp_module_repo="git https://github.com/hatari/hatari :_get_branch_hatari"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_hatari() {
    download "https://api.github.com/repos/${md_id}/${md_id}/tags" - | grep -m 1 name | cut -d\" -f4
}

function depends_hatari() {
    local depends=(
        'cmake'
        'libpng'
        'ninja'
        'portaudio'
        'readline'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}" 
}

function sources_hatari() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|#define HATARI_HOME_DIR \".config/hatari\"|#define HATARI_HOME_DIR \"ArchyPie/configs/hatari\"|g" -i "${md_build}/src/paths.c"

    _sources_capsimage_hatari
}

function _sources_capsimage_hatari() {
    downloadAndExtract "${__archive_url}/spsdeclib_5.1_source.zip" "${md_build}"
    unzip -o capsimg_source_linux_macosx.zip
    chmod u+x capsimg_source_linux_macosx/CAPSImg/configure
}

function _build_capsimage_hatari() {
    cd capsimg_source_linux_macosx/CAPSImg || exit

    # Build CapsImage Library
    ./configure --prefix="${md_build}"
    make clean
    make
    make install
    mv "${md_build}/lib/libcapsimage.so.5.1" "${md_build}/lib/libcapsimage.so.5"

    # Copy CapsImage Headers
    mkdir -p "${md_build}/src/includes/caps"
    cp -R "../LibIPF/"*.h "${md_build}/src/includes/caps/"
    cp "../Core/CommonTypes.h" "${md_build}/src/includes/caps/"
}

function build_hatari() {
    _build_capsimage_hatari

    cd "${md_build}" || exit
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCAPSIMAGE_INCLUDE_DIR="${md_build}/src/includes" \
        -DCAPSIMAGE_LIBRARY="${md_build}/lib/libcapsimage.so.5" \
        -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS} -Wl,-rpath='${md_inst}/lib'" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/src/${md_id}"
}

function install_hatari() {
    ninja -C build install/strip

    # Install: CapsImg Library
    mkdir "${md_inst}/lib"
    cp -Pv "${md_build}/lib"/*.so* "${md_inst}/lib/"

    md_ret_require=(
        "${md_inst}/bin/${md_id}"
        "${md_inst}/lib/libcapsimage.so.5"
    )
}

function configure_hatari() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/atarist/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "atarist"
        mkUserDir "${biosdir}/atarist"
    fi

    local params=("--confirm-quit 0" "--statusbar 0" "--tos ${biosdir}/atarist/tos.img")
    if ! isPlatform "x11" && ! isPlatform "wayland"; then
        params+=("--zoom 1" "-w")
    else
        params+=("-f")
    fi

    addEmulator 1 "${md_id}-fast" "atarist" "${md_inst}/bin/${md_id} ${params[*]} --compatible 0 --timer-d 1 --borders 0 %ROM%"
    addEmulator 0 "${md_id}-fast-borders" "atarist" "${md_inst}/bin/${md_id} ${params[*]} --compatible 0 --timer-d 1 --borders 1 %ROM%"
    addEmulator 0 "${md_id}-compatible" "atarist" "${md_inst}/bin/${md_id} ${params[*]} --compatible 1 --timer-d 0 --borders 0 %ROM%"
    addEmulator 0 "${md_id}-compatible-borders" "atarist" "${md_inst}/bin/${md_id} ${params[*]} --compatible 1 --timer-d 0 --borders 1 %ROM%"

    addSystem "atarist"
}
