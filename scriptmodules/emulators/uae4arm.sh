#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="uae4arm"
rp_module_desc="UAE4ARM (JIT Support) - Commodore Amiga Emulator"
rp_module_help="ROM Extension: .adf .ipf\n\nCopy your Amiga games to $romdir/amiga\n\nCopy the required BIOS files\nkick13.rom\nkick20.rom\nkick31.rom\nto $biosdir/amiga"
rp_module_licence="GPL2"
rp_module_repo="git https://github.com/Chips-fr/uae4arm-rpi.git master"
rp_module_section="opt"
rp_module_flags="!all dispmanx"

function depends_uae4arm() {
    getDepends sdl sdl_mixer sdl_image sdl_gfx sdl_ttf guichan libmpg123 libxml2 flac libmpeg2
}

function sources_uae4arm() {
    gitPullOrClone
}

function build_uae4arm() {
    make clean
    CXXFLAGS="" make PLATFORM=rpi2
    
    md_ret_require="$md_build/uae4arm"
}

function install_uae4arm() {
    md_ret_files=(
        'data'
        'uae4arm'
    )
}

function configure_uae4arm() {
    addEmulator 1 "uae4arm" "amiga" "$md_inst/uae4arm.sh %ROM%"
    addEmulator 0 "uae4arm-a500" "amiga" "$md_inst/uae4arm.sh %ROM% -config=conf/rp-a500.uae"
    addEmulator 0 "uae4arm-a1200" "amiga" "$md_inst/uae4arm.sh %ROM% -config=conf/rp-a1200.uae"
    addSystem "amiga"

    [[ "$md_mode" == "remove" ]] && return

    mkRomDir "amiga"

    mkUserDir "$md_conf_root/amiga"
    mkUserDir "$md_conf_root/amiga/uae4arm"

    # move config / save folders to $md_conf_root/amiga/uae4arm
    local dir
    for dir in conf savestates screenshots; do
        moveConfigDir "$md_inst/$dir" "$md_conf_root/amiga/uae4arm/$dir"
    done

    moveConfigDir "$md_inst/kickstarts" "$biosdir/amiga"
    chown -R "${user}:${user}" "$biosdir/amiga"

    local conf="$(mktemp)"
    iniConfig "=" "" "$conf"
    iniSet "config_description" "RetroPie A500, 68000, OCS, 512KB Chip + 512KB Slow Fast"
    iniSet "chipmem_size" "1"
    iniSet "bogomem_size" "2"
    iniSet "chipset" "ocs"
    iniSet "cachesize" "0"
    iniSet "kickstart_rom_file" "\$(FILE_PATH)/kick13.rom"
    copyDefaultConfig "$conf" "$md_conf_root/amiga/uae4arm/conf/rp-a500.uae"
    rm "$conf"

    conf="$(mktemp)"
    iniConfig "=" "" "$conf"
    iniSet "config_description" "RetroPie A1200, 68EC020, AGA, 2MB Chip"
    iniSet "chipmem_size" "4"
    iniSet "finegrain_cpu_speed" "1024"
    iniSet "cpu_type" "68ec020"
    iniSet "cpu_model" "68020"
    iniSet "chipset" "aga"
    iniSet "cachesize" "0"
    iniSet "kickstart_rom_file" "\$(FILE_PATH)/kick31.rom"
    copyDefaultConfig "$conf" "$md_conf_root/amiga/uae4arm/conf/rp-a1200.uae"
    rm "$conf"

    # copy shared uae4arm/amiberry launch script
    cp "$md_data/uae4arm.sh" "$md_inst/"
    chmod a+x "$md_inst/uae4arm.sh"

    local script="+Start UAE4Arm.sh"
    cat > "$romdir/amiga/$script" << _EOF_
#!/bin/bash
"$md_inst/uae4arm.sh"
_EOF_
    chmod a+x "$romdir/amiga/$script"
    chown "${user}:${user}" "$romdir/amiga/$script"
}
