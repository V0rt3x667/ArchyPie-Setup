#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="ti99sim-sdl1"
rp_module_desc="TI-99/SIM (SDL1 Version) - Texas Instruments Home Computer Emulator"
rp_module_help="ROM Extension: .ctg\n\nCopy your TI-99 games to $romdir/ti99\n\nCopy the required BIOS file TI-994A.ctg (case sensitive) to $biosdir"
rp_module_licence="GPL2 http://www.mrousseau.org/programs/ti99sim/"
rp_module_repo="file $__archive_url/ti99sim-0.15.0.src.tar.gz"
rp_module_section="exp"
rp_module_flags="sdl1 !mali"

function depends_ti99sim-sdl1() {
    getDepends sdl openssl boost-libs
}

function sources_ti99sim-sdl1() {
    downloadAndExtract "$md_repo_url" "$md_build" --strip-components 1
}

function build_ti99sim-sdl1() {
    build_ti99sim
}

function install_ti99sim-sdl1() {
    install_ti99sim
}

function configure_ti99sim-sdl1() {
    mkRomDir "ti99"

    addEmulator 0 "$md_id" "ti99" "$md_inst/ti99sim.sh -f %ROM%"
    addSystem "ti99"

    [[ "$md_mode" == "remove" ]] && return

    isPlatform "dispmanx" && setBackend "$md_id" "dispmanx"

    moveConfigDir "$home/.ti99sim" "$md_conf_root/ti99/"
    ln -sf "$biosdir/TI-994A.ctg" "$md_inst/TI-994A.ctg"

    local file="$md_inst/ti99sim.sh"
    cat >"$file" << _EOF_
#!/bin/bash
pushd "$md_inst"
./ti99sim-sdl "\$@"
popd
_EOF_
    chmod +x "$file"
}
