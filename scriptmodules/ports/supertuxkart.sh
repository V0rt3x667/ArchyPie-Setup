#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="supertuxkart"
rp_module_desc="SuperTuxKart: 3D Kart Racing Game Featuring Tux & Friends"
rp_module_licence="GPL3 https://raw.githubusercontent.com/supertuxkart/stk-code/master/COPYING"
rp_module_repo="file https://github.com/supertuxkart/stk-code/releases/download/1.4/supertuxkart-1.4-src.tar.xz"
rp_module_section="opt"

function _get_branch_supertuxkart() {
    download "https://api.github.com/repos/supertuxkart/stk-code/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_supertuxkart() {
    local depends=(
        'bluez-libs'
        'clang'
        'cmake'
        'curl'
        'freetype2'
        'fribidi'
        'glew'
        'glu'
        'libjpeg-turbo'
        'libpng'
        'libraqm'
        'libsquish'
        'libvorbis'
        'libvpx'
        'lld'
        'mcpp'
        'ninja'
        'openal'
        'openssl'
        'sdl2'
        'shaderc'
        'sqlite'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_supertuxkart() {
    # Grab The Source Code & Assets From The Current Github Release, Quicker Than Cloning From Subversion
    downloadAndExtract "${md_repo_url}" "${md_build}" --strip-components 1

    # Fix Build Errors
    applyPatch "${md_data}/01_add_missing_includes.patch"

    # Set Default Config Path(s)
    sed -e "s|\".local/share\",|\"ArchyPie/configs\",|g" -i "${md_build}/src/io/file_manager.cpp"
    sed -e "s|m_user_config_dir += \"/.config\";|m_user_config_dir += \"/ArchyPie/configs\";|g" -i "${md_build}/src/io/file_manager.cpp"
    sed -e "s|find \"\$HOME/.config/${md_id}\"|find \"\$HOME/ArchyPie/configs/${md_id}\"|g" -i "${md_build}/tools/run_server.sh"
}

function build_supertuxkart() {
    local params=()

    isPlatform "arm" && params+=("-DUSE_GLES2")

    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_EXE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_MODULE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_SHARED_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DBUILD_EXAMPLE_SDL="OFF" \
        -DBUILD_EXAMPLE="OFF" \
        -DBUILD_RECORDER="OFF" \
        "${params[@]}" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/bin/${md_id}"
}

function install_supertuxkart() {
    ninja -C build install/strip
}

function configure_supertuxkart() {
    local portname
    portname="supertuxkart"

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    addPort "${md_id}" "${portname}" "SuperTuxKart" "${md_inst}/bin/${md_id} --fullscreen"
}
