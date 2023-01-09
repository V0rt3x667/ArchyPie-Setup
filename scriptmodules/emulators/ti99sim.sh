#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="ti99sim"
rp_module_desc="TI-99/SIM - Texas Instruments Home Computer Emulator"
rp_module_help="ROM Extension: .ctg\n\nCopy your TI-99 games to $romdir/ti99\n\nCopy the required BIOS file TI-994A.ctg (case sensitive) to $biosdir"
rp_module_licence="GPL2 https://www.mrousseau.org/programs/ti99sim"
rp_module_repo="file $__archive_url/ti99sim-0.16.0.src.tar.gz"
rp_module_section="exp"
rp_module_flags=""

function depends_ti99sim() {
    getDepends sdl2 openssl
}

function sources_ti99sim() {
    downloadAndExtract "$md_repo_url" "$md_build" --strip-components 1
    sed s'|LFLAGS += -Wl,--gc-sections|LFLAGS += -Wl,-O1,--sort-common,--as-needed,-z,relro,-z,now,--gc-sections|'g -i ./rules.mak
}

function build_ti99sim() {
    make clean
    make
}

function install_ti99sim() {
    md_ret_files=(
        'bin/ti99sim-sdl'
        'bin/convert-ctg'
        'bin/catalog'
        'bin/disk'
        'bin/dumpgrom'
        'bin/mkcart'
        'bin/ti99sim-console'
        'doc/COPYING'
        'doc/main.css'
        'doc/README.html'
    )
}

function configure_ti99sim() {
    mkRomDir "ti99"

    addEmulator 1 "$md_id" "ti99" "$md_inst/ti99sim.sh -f %ROM%"
    addSystem "ti99"

    [[ "$md_mode" == "remove" ]] && return

    moveConfigDir "$home/.ti99sim" "$md_conf_root/ti99/"
    ln -sf "$biosdir/TI-994A.ctg" "$md_inst/TI-994A.ctg"

    local file="$md_inst/ti99sim.sh"
    cat >"${file}" << _EOF_
#!/bin/bash
pushd "$md_inst"
./ti99sim-sdl "\$@"
popd
_EOF_
    chmod +x "${file}"
}
