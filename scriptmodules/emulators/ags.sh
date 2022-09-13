#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="ags"
rp_module_desc="Adventure Game Studio - Adventure Game Engine"
rp_module_help="ROM Extension: .exe\n\nCopy Adventure Game Studio Games to: $romdir/ags"
rp_module_licence="OTHER https://raw.githubusercontent.com/adventuregamestudio/ags/master/License.txt"
rp_module_repo="git https://github.com/adventuregamestudio/ags.git :_get_branch_ags"
rp_module_section="opt"
rp_module_flags="!mali"

function _get_branch_ags() {
    download https://api.github.com/repos/adventuregamestudio/ags/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_ags() {
    local depends=(
        'allegro'
        'cmake'
        'dumb'
        'freetype2'
        'libogg'
        'libtheora'
        'libvorbis'
        'libxxf86vm'
        'ninja'
        'xorg-server'
    )
    getDepends "${depends[@]}"
}

function sources_ags() {
    gitPullOrClone
}

function build_ags() {
    cmake . \
        -GNinja \
        -Bbuild \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="$md_build/build/ags"
}

function install_ags() {
    ninja -C build install/strip
}

function configure_ags() {
    if [[ "$md_mode" == "install" ]]; then
        mkRomDir "ags"

        # Install Eawpatches GUS Patch Set (See: http://liballeg.org/digmid.html)
        download "http://www.eglebbk.dds.nl/program/download/digmid.dat" - | bzcat >"$md_inst/bin/patches.dat"
    fi

    local binary="XINIT:$md_inst/bin/ags"
    local params=("--fullscreen %ROM%")
    if ! isPlatform "x11"; then
        params+=("--gfxdriver software")
    fi
    addEmulator 1 "$md_id" "ags" "$binary ${params[*]}" "Adventure Game Studio" ".exe"

    addSystem "ags"
}
