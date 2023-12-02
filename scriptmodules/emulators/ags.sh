#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="ags"
rp_module_desc="Adventure Game Studio: Adventure Game Engine (AGS 3 Branch ≥ 2.50)"
rp_module_help="ROM Extension: .ags .exe\n\nCopy Adventure Game Studio Games To: ${romdir}/ags"
rp_module_licence="OTHER https://raw.githubusercontent.com/adventuregamestudio/ags/master/License.txt"
rp_module_repo="git https://github.com/adventuregamestudio/ags :_get_branch_ags"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_ags() {
    download "https://api.github.com/repos/adventuregamestudio/ags/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_ags() {
    local depends=(
        'clang'
        'cmake'
        'doxygen'
        'freetype2'
        'libogg'
        'libtheora'
        'libvorbis'
        'libxxf86vm'
        'lld'
        'ninja'
        'sdl2_mixer'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_ags() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|.Concat(\".local/share\");|.Concat(\"ArchyPie/configs\");|g" -i "${md_build}/Engine/platform/base/agsplatform_xdg_unix.cpp"
}

function build_ags() {
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
        -DAGS_USE_LOCAL_ALL_LIBRARIES="ON" \
        -DAGS_USE_LOCAL_SDL2_SOUND="OFF" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/${md_id}"
}

function install_ags() {
    ninja -C build install/strip
}

function configure_ags() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "${md_id}"
    fi

    addEmulator 1 "${md_id}" "${md_id}" "${md_inst}/bin/${md_id} --gfxdriver ogl --fullscreen %ROM%"

    addSystem "${md_id}"
}
