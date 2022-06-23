#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="hypseus"
rp_module_desc="Hypseus Singe - Super Multiple Arcade Laserdisc Emulator"
rp_module_help="ROM Extension: .daphne\n\nCopy Your Laserdisc ROMs to $romdir/daphne"
rp_module_licence="GPL3 https://raw.githubusercontent.com/DirtBagXon/hypseus-singe/master/LICENSE"
rp_module_repo="git https://github.com/DirtBagXon/hypseus-singe.git :_get_branch_hypseus"
rp_module_section="main"
rp_module_flags=""

function _get_branch_hypseus() {
    if isPlatform "rpi"; then
        RetroPie
    else
        download https://api.github.com/repos/DirtBagXon/hypseus-singe/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
    fi
}

function depends_hypseus() {
    local depends=(
        'cmake'
        'libmpeg2'
        'libogg'
        'libvorbis'
        'sdl2'
        'sdl2_image'
        'sdl2_ttf'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_hypseus() {
    gitPullOrClone
}

function build_hypseus() {
    # Does not currently build with Ninja.
    rpSwap on 1024
    cmake . \
        -Ssrc \
        -Bbuild \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -Wno-dev
    make -C build clean
    make -C build
    rpSwap off

    cp build/hypseus hypseus.bin
    md_ret_require="hypseus.bin"
}

function install_hypseus() {
    md_ret_files=(
        'sound'
        'pics'
        'fonts'
        'hypseus.bin'
        'LICENSE'
    )
}

function configure_hypseus() {
    mkRomDir "daphne"
    mkRomDir "daphne/roms"

    addEmulator 0 "$md_id" "daphne" "$md_inst/hypseus.sh %ROM%"
    addSystem "daphne"

    [[ "$md_mode" == "remove" ]] && return

    mkUserDir "$md_conf_root/daphne"

    local dir
    for dir in ram logs screenshots; do
        mkUserDir "$md_conf_root/daphne/$dir"
        ln -snf "$md_conf_root/daphne/$dir" "$md_inst/$dir"
    done

    copyDefaultConfig "$md_data/hypinput.ini" "$md_conf_root/daphne/hypinput.ini"

    ln -snf "$romdir/daphne/roms" "$md_inst/roms"
    ln -snf "$romdir/daphne/roms" "$md_inst/singe"

    ln -sf "$md_conf_root/daphne/hypinput.ini" "$md_inst/hypinput.ini"

    local common_args="-framefile \"\$dir/\$name.txt\" -homedir \"$md_inst\" -fullscreen \$params"

    cat >"$md_inst/hypseus.sh" <<_EOF_
#!/bin/bash
dir="\$1"
name="\${dir##*/}"
name="\${name%.*}"

if [[ -f "\$dir/\$name.commands" ]]; then
    params=\$(<"\$dir/\$name.commands")
fi

if [[ -f "\$dir/\$name.singe" ]]; then
    "$md_inst/hypseus.bin" singe vldp -retropath -manymouse -script "\$dir/\$name.singe" $common_args
else
    "$md_inst/hypseus.bin" "\$name" vldp $common_args
fi
_EOF_
    chmod +x "$md_inst/hypseus.sh"
    mkdir -p "$md_inst/framefile"
}
