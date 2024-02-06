#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="love"
rp_module_desc="Love: A 2D Game Engine For Lua"
rp_module_help="Copy Love Games To: ${romdir}/love"
rp_module_licence="ZLIB https://raw.githubusercontent.com/love2d/love/master/license.txt"
rp_module_repo="git https://github.com/love2d/love :_get_branch_love"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_love() {
    download "https://api.github.com/repos/love2d/love/releases" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_love() {
    local depends=(
        'clang'
        'cmake'
        'freetype2'
        'libjpeg-turbo'
        'libmodplug'
        'libpng'
        'libtheora'
        'libvorbis'
        'lld'
        'luajit'
        'mpg123'
        'ninja'
        'openal'
        'physfs'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_love() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed "s|.local/share/|ArchyPie/configs/|g" -i "${md_build}/src/libraries/physfs/physfs_platform_unix.c" "${md_build}/src/modules/filesystem/physfs/Filesystem.cpp"
}

function build_love() {
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
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/${md_id}"
}

function install_love() {
    md_ret_files=(
        'build/love'
        'build/libliblove.so'
    )
}

function _game_data_love() {
    # Get Mari0 1.6.2 (Freeware Game Data)
    if [[ ! -f "${romdir}/${md_id}/mari0.love" ]]; then
        downloadAndExtract "https://github.com/Stabyourself/mari0/archive/1.6.2.tar.gz" "${__tmpdir}/mari0" --strip-components 1
        pushd "${__tmpdir}/mari0" || return
        zip -qr "${romdir}/${md_id}/mari0.love" .
        popd || return
        rm -fr "${__tmpdir}/mari0"
        chown "${user}:${user}" "${romdir}/${md_id}/mari0.love"
    fi
}

function configure_love() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "${md_id}"
        _game_data_love
    fi

    setConfigRoot ""

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    addEmulator 1 "${md_id}" "${md_id}" "${md_inst}/${md_id} %ROM%"

    addSystem "${md_id}"
}
