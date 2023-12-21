#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="bombermaaan"
rp_module_desc="Bombermaaan: Bomberman Clone"
rp_module_licence="GPL3 https://raw.githubusercontent.com/bjaraujo/Bombermaaan/master/LICENSE.txt"
rp_module_repo="git https://github.com/bjaraujo/Bombermaaan master"
rp_module_section="exp"
rp_module_flags=""

function depends_bombermaaan() {
    local depends=(
        'clang'
        'cmake'
        'lld'
        'ninja'
        'python'
        'sdl_mixer'
        'sdl12-compat'
        'sdl2_mixer'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_bombermaaan() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|append(\"/.Bombermaaan/\");|append(\"/ArchyPie/configs/${md_id}/\");|g" -i "${md_build}/trunk/src/CGame.cpp"

    # Set Fullscreen By Default
    sed -e "s|DISPLAYMODE_WINDOWED;|DISPLAYMODE_FULL3;|g" -i "${md_build}/trunk/src/COptions.cpp"

    # "SDL 1 Classic" Is Required To Build Bombermaaan, The "sdl12-compat" Package Is Used To Run Bombermaaan
    _sources_sdl
}

function _sources_sdl() {
    gitPullOrClone "${md_build}/sdl" "https://github.com/libsdl-org/SDL-1.2" "main"
}

function _build_sdl() {
    cd sdl || exit
    ./autogen.sh
    ./configure --disable-rpath --disable-static
    make clean
    make
}

function build_bombermaaan() {
    _build_sdl && cd "${md_build}" || exit

    cmake . \
        -B"build" \
        -G"Ninja" \
        -S"trunk" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_EXE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_MODULE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_SHARED_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DLOAD_RESOURCES_FROM_FILES="ON" \
        -DSDL_INCLUDE_DIR="${md_build}/sdl/include" \
        -DSDL_LIBRARY="${md_build}/sdl/build/.libs/libSDL.so" \
        -DSDLMAIN_LIBRARY="${md_build}/sdl/build/.libs/libSDLmain.a" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/bin/Bombermaaan"
}

function install_bombermaaan() {
    ninja -C build install/strip
}

function configure_bombermaaan() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    addPort "${md_id}" "${md_id}" "Bombermaaan" "${md_inst}/Bombermaaan"
}
