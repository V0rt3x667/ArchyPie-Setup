#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-fbneo"
rp_module_desc="FinalBurn Neo Arcade Libretro Core"
rp_module_help="ROM Extension: .zip\n\nCopy your FBA roms to\n$romdir/fba or\n$romdir/neogeo or\n$romdir/arcade\n\nFor NeoGeo games the neogeo.zip BIOS is required and must be placed in the same directory as your FBA roms."
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/FBNeo/master/src/license.txt"
rp_module_repo="git https://github.com/libretro/FBNeo master"
rp_module_section="main"

function sources_lr-fbneo() {
    gitPullOrClone
}

function build_lr-fbneo() {
    cd src/burner/libretro
    local params=()
    isPlatform "arm" && params+=(USE_CYCLONE=1)
    isPlatform "neon" && params+=(HAVE_NEON=1)
    isPlatform "x86" && isPlatform "64bit" && params+=(USE_X64_DRC=1)
    make clean
    make "${params[@]}"
    md_ret_require="$md_build/src/burner/libretro/fbneo_libretro.so"
}

function install_lr-fbneo() {
    md_ret_files=(
        'fbahelpfilesrc/fbneo.chm'
        'src/burner/libretro/fbneo_libretro.so'
        'gamelist.txt'
        'whatsnew.html'
        'metadata'
        'dats'
    )
}

function configure_lr-fbneo() {
    addEmulator 0 "$md_id" "arcade" "$md_inst/fbneo_libretro.so"
    addEmulator 0 "$md_id-neocd" "arcade" "$md_inst/fbneo_libretro.so --subsystem neocd"
    addEmulator 1 "$md_id" "neogeo" "$md_inst/fbneo_libretro.so"
    addEmulator 0 "$md_id-neocd" "neogeo" "$md_inst/fbneo_libretro.so --subsystem neocd"
    addEmulator 1 "$md_id" "fba" "$md_inst/fbneo_libretro.so"
    addEmulator 0 "$md_id-neocd" "fba" "$md_inst/fbneo_libretro.so --subsystem neocd"

    addEmulator 0 "$md_id-pce" "pcengine" "$md_inst/fbneo_libretro.so --subsystem pce"
    addEmulator 0 "$md_id-sgx" "pcengine" "$md_inst/fbneo_libretro.so --subsystem sgx"
    addEmulator 0 "$md_id-tg" "pcengine" "$md_inst/fbneo_libretro.so --subsystem tg"
    addEmulator 0 "$md_id-gg" "gamegear" "$md_inst/fbneo_libretro.so --subsystem gg"
    addEmulator 0 "$md_id-sms" "mastersystem" "$md_inst/fbneo_libretro.so --subsystem sms"
    addEmulator 0 "$md_id-md" "megadrive" "$md_inst/fbneo_libretro.so --subsystem md"
    addEmulator 0 "$md_id-sg1k" "sg-1000" "$md_inst/fbneo_libretro.so --subsystem sg1k"
    addEmulator 0 "$md_id-cv" "coleco" "$md_inst/fbneo_libretro.so --subsystem cv"
    addEmulator 0 "$md_id-msx" "msx" "$md_inst/fbneo_libretro.so --subsystem msx"
    addEmulator 0 "$md_id-spec" "zxspectrum" "$md_inst/fbneo_libretro.so --subsystem spec"
    addEmulator 0 "$md_id-fds" "fds" "$md_inst/fbneo_libretro.so --subsystem fds"
    addEmulator 0 "$md_id-nes" "nes" "$md_inst/fbneo_libretro.so --subsystem nes"
    addEmulator 0 "$md_id-ngp" "ngp" "$md_inst/fbneo_libretro.so --subsystem ngp"
    addEmulator 0 "$md_id-ngpc" "ngpc" "$md_inst/fbneo_libretro.so --subsystem ngp"
    addEmulator 0 "$md_id-chf" "channelf" "$md_inst/fbneo_libretro.so --subsystem chf"

    local systems=(
        "arcade"
        "neogeo"
        "fba"
        "pcengine"
        "gamegear"
        "mastersystem"
        "megadrive"
        "sg-1000"
        "coleco"
        "msx"
        "zxspectrum"
        "fds"
        "nes"
        "ngp"
        "ngpc"
        "channelf"
    )

    local system
    for system in "${systems[@]}"; do
        addSystem "$system"
    done

    [[ "$md_mode" == "remove" ]] && return

    for system in "${systems[@]}"; do
        mkRomDir "$system"
        defaultRAConfig "$system"
    done

    # Create directories for all support files
    mkUserDir "$biosdir/fbneo"
    mkUserDir "$biosdir/fbneo/blend"
    mkUserDir "$biosdir/fbneo/cheats"
    mkUserDir "$biosdir/fbneo/patched"
    mkUserDir "$biosdir/fbneo/samples"

    # copy hiscore.dat
    cp "$md_inst/metadata/hiscore.dat" "$biosdir/fbneo/"
    chown "${user}:${user}" "$biosdir/fbneo/hiscore.dat"

    # Set core options
    setRetroArchCoreOption "fbneo-diagnostic-input" "Hold Start"
}
