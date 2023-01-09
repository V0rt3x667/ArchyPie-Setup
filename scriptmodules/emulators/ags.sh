#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="ags"
rp_module_desc="Adventure Game Studio: Adventure Game Engine (AGS 3 Branch ≥ 2.50)"
rp_module_help="ROM Extension: .ags .exe\n\nCopy Adventure Game Studio Games To: ${romdir}/ags"
rp_module_licence="OTHER https://raw.githubusercontent.com/adventuregamestudio/ags/master/License.txt"
rp_module_repo="git https://github.com/adventuregamestudio/ags.git :_get_branch_ags"
rp_module_section="opt"
rp_module_flags="!wayland xwayland"

function _get_branch_ags() {
    download "https://api.github.com/repos/adventuregamestudio/${md_id}/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_ags() {
    local depends=(
        'cmake'
        'doxygen'
        'freetype2'
        'libogg'
        'libtheora'
        'libvorbis'
        'libxxf86vm'
        'ninja'
        'sdl2_mixer'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_ags() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|.Concat(\".local/share\");|.Concat(\"ArchyPie/configs\");|g" -i "${md_build}/Engine/platform/linux/acpllnx.cpp"
}

function build_ags() {
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
    md_ret_require="${md_build}/build/${md_id}"
}

function install_ags() {
    ninja -C build install/strip
}

function configure_ags() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "${md_id}"

        # Install Eawpatches GUS Patch Set (See: "http://liballeg.org/digmid.html")
        download "http://www.eglebbk.dds.nl/program/download/digmid.dat" - | bzcat >"${md_inst}/bin/patches.dat"
    fi

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    addEmulator 1 "${md_id}" "${md_id}" "${md_inst}/bin/${md_id} --fullscreen %ROM%"

    addSystem "${md_id}"
}
