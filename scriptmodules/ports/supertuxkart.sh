#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="supertuxkart"
rp_module_desc="SuperTuxKart: 3D Kart Racing Game Featuring Tux & Friends"
rp_module_licence="GPL3 https://raw.githubusercontent.com/supertuxkart/stk-code/master/COPYING"
rp_module_repo="git https://github.com/supertuxkart/stk-code :_get_branch_supertuxkart"
rp_module_section="opt"

function _get_branch_supertuxkart() {
    download "https://api.github.com/repos/${md_id}/stk-code/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_supertuxkart() {
    local depends=(
        'bluez-libs'
        'cmake'
        'curl'
        'freetype2'
        'fribidi'
        'glew'
        'glu'
        'libjpeg-turbo'
        'libpng'
        'libraqm'
        'libvorbis'
        'libvpx'
        'libxkbcommon'
        'mcpp'
        'mesa-libgl'
        'mesa'
        'ninja'
        'openal'
        'openssl'
        'sdl2'
        'sqlite'
        'subversion'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_supertuxkart() {
    local ver
    ver="$(_get_branch_supertuxkart)"

    downloadAndExtract "https://github.com/${md_id}/stk-code/releases/download/${ver}/${md_id}-${ver}-src.tar.xz" "${md_build}" --strip-components 1

    # Set Default Config Path(s)
    sed -e "s|\".local/share\",|\"ArchyPie/configs\",|g" -i "${md_build}/src/io/file_manager.cpp"
    sed -e "s|m_user_config_dir += \"/.config\";|m_user_config_dir += \"/ArchyPie/configs\";|g" -i "${md_build}/src/io/file_manager.cpp"
    sed -e "s|find \"\$HOME/.config/${md_id}\"|find \"\$HOME/ArchyPie/configs/${md_id}\"|g" -i "${md_build}/tools/run_server.sh"
}

function build_supertuxkart() {
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DBUILD_RECORDER="OFF" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/bin/${md_id}"
}

function install_supertuxkart() {
    ninja -C build install/strip
}

function configure_supertuxkart() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    addPort "${md_id}" "${md_id}" "SuperTuxKart" "${md_inst}/bin/${md_id} --fullscreen"
}
