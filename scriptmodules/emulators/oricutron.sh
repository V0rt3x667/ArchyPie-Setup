#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="oricutron"
rp_module_desc="Oricutron: Tangerine Computer Systems Oric-1, Atmos, Stratos, Telestrat & Pravetz 8D Emulator"
rp_module_help="ROM Extensions: .dsk .tap\n\nCopy Oric Games To: ${romdir}/oric"
rp_module_licence="GPL2 https://raw.githubusercontent.com/pete-gordon/oricutron/4c359acfb6bd36d44e6d37891d7b6453324faf7d/main.h"
rp_module_repo="git https://github.com/pete-gordon/oricutron :_get_branch_oricutron"
rp_module_section="exp"

function _get_branch_oricutron() {
    download "https://api.github.com/repos/pete-gordon/${md_id}/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_oricutron() {
    local depends=(
        'cmake'
        'ninja'
        'sdl2'
    )
    isPlatform "x11" && depends+=('gtk3')

    getDepends "${depends[@]}"
}

function sources_oricutron() {
    gitPullOrClone

    # Extract Disks & ROMs From Source Code Snap Shot
    downloadAndExtract "http://www.petergordon.org.uk/oricutron/files/Oricutron_src_v12.zip" "${md_build}/data"
}

function build_oricutron() {
    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DUSE_SDL2="ON" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/Oricutron-sdl2"
}

function install_oricutron() {
    md_ret_files=(
        'build/Oricutron-sdl2'
        'data/disks'
        'data/images'
        'data/roms'
        'data/tapes'
        'oricutron.cfg'
    )

    mv "${md_inst}/roms/MICRODIS.ROM" "${md_inst}/roms/microdis.rom"
}

function configure_oricutron() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "oric"
    fi

    local default
    local machines=(
        'atmos'
        'o16k'
        'oric1'
        'pravetz'
        'telestrat'
    )
    for machine in "${machines[@]}"; do
        default=0
        [[ "${machine}" == "atmos" ]] && default=1
        addEmulator "${default}" "${md_id}-${machine}" "oric" "pushd ${md_inst}; ${md_inst}/Oricutron-sdl2 --machine ${machine} %ROM% --fullscreen; popd"
    done

    addSystem "oric"
}
