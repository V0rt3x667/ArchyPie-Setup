#!/bin/bash

################################################################################
# This file is part of the ArchyPie Project                                    #
#                                                                              #
# Please see the LICENSE file at the top-level directory of this distribution. #
################################################################################

rp_module_id="cdogs-sdl"
rp_module_desc="C-Dogs SDL: Classic Overhead Run-&-Gun Game"
rp_module_licence="GPL2 https://raw.githubusercontent.com/cxong/cdogs-sdl/master/COPYING"
rp_module_repo="git https://github.com/cxong/cdogs-sdl :_get_release_cdogs-sdl"
rp_module_section="exp"
rp_module_flags="all sdl2"

function _get_release_cdogs-sdl() {
    # Current release
    local release="2.2.0"

    echo "${release}"
}

function depends_cdogs-sdl() {
    local depends=(
        'clang'
        'cmake'
        'enet'
        'libarchive'
        'mold'
        'ninja'
        'sdl2_image'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_cdogs-sdl() {
    gitPullOrClone

    # Download extra missions
    download "https://cxong.github.io/${md_id}/missionpack.zip" - | bsdtar xvf - --strip-components=1 -C "${md_build}"

    # Set default config path(s)
    sed "s|\".config/${md_id}/\"|\"${md_conf_root}/${md_id}/\"|g" -i "${md_build}/CMakeLists.txt"

    # The Arch Linux Team Have Broken 'SDL2_Mixer' Since '2.6.3-2' By Compiling It With Non-Default Options
    #applyPatch "${md_data}/01_fix_sdl2_mixer.patch"
    #_sources_sdl2_mixer
}

#function _sources_sdl2_mixer() {
#    gitPullOrClone "${md_build}/sdl2_mixer" "https://github.com/libsdl-org/SDL_mixer" "main" "a37e09f"
#}

#function _build_sdl2_mixer() {
#    cd sdl2_mixer || exit
#    ./configure --disable-shared --prefix="${md_build}/depends"
#    make clean
#    make && make install
#}

function build_cdogs-sdl() {
#     _build_sdl2_mixer && cd "${md_build}" || exit

    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_LINKER_TYPE="MOLD" \
        -DBUILD_EDITOR="OFF" \
        -DBUILD_TESTING="OFF" \
        -DCDOGS_DATA_DIR="${md_inst}/" \
        -DUSE_SHARED_ENET="ON" \
        -DCMAKE_PREFIX_PATH="${rootdir}/supplementary/sdl2" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/src/${md_id}"
}

function install_cdogs-sdl() {
    #ninja -C build install/strip

    md_ret_files=(
        'data'
        'dogfights'
        'graphics'
        'missions'
        'music'
        'sounds'
        'build/cdogs-sdl'
    )
    # Install licence
    install -D644 COPYING -t "${md_inst}/LICENCE"
}

function configure_cdogs-sdl() {
    #moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    #addPort "${md_id}" "${md_id}" "C-Dogs SDL" "${md_inst}/bin/${md_id} --fullscreen"
    addPort "${md_id}" "${md_id}" "C-Dogs SDL" "${md_inst}/${md_id} --fullscreen"
}
