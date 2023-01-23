#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="simcoupe"
rp_module_desc="SimCoupe: SAM Coupé Emulator"
rp_module_help="ROM Extensions: .dsk .mgt .sad .sbt\n\nCopy SAM Coupé Games To: ${romdir}/samcoupe"
rp_module_licence="GPL2 https://raw.githubusercontent.com/simonowen/simcoupe/master/License.txt"
rp_module_repo="git https://github.com/simonowen/simcoupe :_get_branch_simcoupe"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_simcoupe() {
    download "https://api.github.com/repos/simonowen/${md_id}/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
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

    # Set Default Config Path(s)
    sed -e "s|\".simcoupe\"|\"ArchyPie/configs/${md_id}\"|g" -i "${md_build}/SDL/OSD.cpp"
}

function build_simcoupe() {
    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS} -Wl,-rpath='${md_inst}/lib'" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/${md_id}"
}

function install_simcoupe() {
    ninja -C build install/strip
    md_ret_require="${md_inst}/bin/${md_id}"
}

function configure_simcoupe() {
    mkRomDir "samcoupe"

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/samcoupe/${md_id}"

    addEmulator 1 "$md_id" "samcoupe" "$md_inst/bin/${md_id} autoboot -disk1 %ROM% -fullscreen"

    addSystem "samcoupe"
}
