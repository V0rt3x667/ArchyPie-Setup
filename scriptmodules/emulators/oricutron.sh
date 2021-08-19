#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="oricutron"
rp_module_desc="Oricutron - Tangerine Computer Systems Oric-1, Atmos, Stratos, Telestrat & Pravetz 8D Emulator"
rp_module_help="ROM Extensions: .dsk .tap\n\nCopy your Oric games to $romdir/oric"
rp_module_licence="GPL2 https://raw.githubusercontent.com/pete-gordon/oricutron/4c359acfb6bd36d44e6d37891d7b6453324faf7d/main.h"
rp_module_repo="git https://github.com/pete-gordon/oricutron.git :_get_branch_oricutron"
rp_module_section="exp"

function _get_branch_oricutron() {
    download https://api.github.com/repos/pete-gordon/oricutron/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_oricutron() {
    local depends=('cmake' 'sdl2')
    isPlatform "x11" && depends+=('gtk3')
    getDepends "${depends[@]}"
}

function sources_oricutron() {
    gitPullOrClone
}

function build_oricutron() {
#    make clean
#    if isPlatform "rpi" || isPlatform "mali"; then
#        make PLATFORM=rpi SDL_LIB=sdl2
#    else
#        make SDL_LIB=sdl2
#    fi

    mkdir build
    cd build
    cmake .. \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_TYPE="Release"
    make clean
    make 
    md_ret_require="$md_build/build/Oricutron"
}

function install_oricutron() {
    md_ret_files=(
        'build/Oricutron'
        'oricutron.cfg'
        'roms'
        'disks'
        'images'
    )
}

function configure_oricutron() {
    mkRomDir "oric"

    local machine
    local default
    for machine in atmos oric1 o16k telestrat pravetz; do
        default=0
        [[ "$machine" == "atmos" ]] && default=1
        addEmulator "$default" "$md_id-$machine" "oric" "pushd $md_inst; $md_inst/Oricutron --machine $machine %ROM% --fullscreen; popd"
    done
    addSystem "oric"
}
