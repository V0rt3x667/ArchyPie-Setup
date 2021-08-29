#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="micropolis"
rp_module_desc="Micropolis - Open Source City Building Game"
rp_module_licence="GPL3 https://www.donhopkins.com/home/micropolis/#license"
rp_module_repo="file https://www.donhopkins.com/home/micropolis/micropolis-activity-source.tgz"
rp_module_section="opt"
rp_module_flags="!mali"

function depends_micropolis() {
    local depends=(
        'inetutils'
        'libxpm'
        'sdl_mixer'
    )
    ! isPlatform "x11" && depends+=('xorg-server') && pacmanpkg archy-matchbox-window-manager
    getDepends "${depends[@]}"
}

function sources_micropolis() {
    downloadAndExtract "$md_repo_url" "$md_build" --strip-components 1
    applyPatch "$md_data/01_fix_build_issues.patch"
}

function build_micropolis() {
    make -C src clean
    make -C src
    md_ret_require="$md_build/src/sim/sim"
}

function install_micropolis() {
    cp src/sim/sim res/sim
    make -C src PREFIX="$md_inst" LIBEXECDIR="$md_inst/lib" install
}

function configure_micropolis() {
    local binary="$md_inst/bin/micropolis"
    ! isPlatform "x11" && binary="XINIT:$md_inst/micropolis.sh"

    addPort "$md_id" "micropolis" "Micropolis" "$binary"

    mkdir -p "$md_inst"
    cat >"$md_inst/micropolis.sh" << _EOF_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager &
/usr/games/micropolis
_EOF_
    chmod +x "$md_inst/micropolis.sh"
}
