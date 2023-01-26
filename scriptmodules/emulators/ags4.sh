#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="ags4"
rp_module_desc="Adventure Game Studio: Adventure Game Engine (AGS 4 Branch ≥ 3.4.1)"
rp_module_help="ROM Extension: .ags .exe\n\nCopy Adventure Game Studio Games To: ${romdir}/ags"
rp_module_licence="OTHER https://raw.githubusercontent.com/adventuregamestudio/ags/master/License.txt"
rp_module_repo="git https://github.com/adventuregamestudio/ags ags4"
rp_module_section="opt"
rp_module_flags=""

function depends_ags4() {
    local depends=(
        'cmake'
        'doxygen'
        'freetype2'
        'libogg'
        'libtheora'
        'libvorbis'
        'ninja'
        'sdl2_mixer'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_ags4() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|.Concat(\".local/share\");|.Concat(\"ArchyPie/configs\");|g" -i "${md_build}/Engine/platform/base/agsplatform_xdg_unix.cpp"
}

function build_ags4() {
    # Disable LTO
    export LDFLAGS="${LDFLAGS} -fno-lto"
    cmake . \
        -GNinja \
        -Bbuild \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DAGS_USE_LOCAL_OGG="ON" \
        -DAGS_USE_LOCAL_THEORA="ON" \
        -DAGS_USE_LOCAL_VORBIS="ON" \
        -DAGS_USE_LOCAL_SDL2="ON" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/${md_id/4/}"
}

function install_ags4() {
    ninja -C build install/strip
}

function configure_ags4() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "${md_id/4/}"
    fi

    moveConfigDir "${arpdir}/${md_id/4/}" "${md_conf_root}/${md_id/4/}/"

    addEmulator 0 "${md_id}" "${md_id/4/}" "${md_inst}/bin/${md_id/4/} --fullscreen %ROM%"

    addSystem "${md_id/4/}"
}
