#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="simcoupe"
rp_module_desc="SimCoupe - SAM Coupé Emulator"
rp_module_help="ROM Extensions: .dsk .mgt .sbt .sad\n\nCopy your SAM Coupe games to $romdir/samcoupe."
rp_module_licence="GPL2 https://raw.githubusercontent.com/simonowen/simcoupe/master/License.txt"
rp_module_repo="git https://github.com/simonowen/simcoupe.git :_get_branch_simcoupe"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_simcoupe() {
    download https://api.github.com/repos/simonowen/simcoupe/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_simcoupe() {
    local depends=(
        'bzip2'
        'cmake'
        'ninja'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_simcoupe() {
    gitPullOrClone
}

function build_simcoupe() {
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS} -Wl,-rpath='$md_inst/lib'" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="$md_build/build/simcoupe"
}

function install_simcoupe() {
    ninja -C build install/strip
}

function configure_simcoupe() {
    mkRomDir "samcoupe"
    moveConfigDir "$home/.simcoupe" "$md_conf_root/$md_id"

    addEmulator 1 "$md_id" "samcoupe" "$md_inst/bin/simcoupe autoboot -disk1 %ROM% -fullscreen"
    addSystem "samcoupe"
}
