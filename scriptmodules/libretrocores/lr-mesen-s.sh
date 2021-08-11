#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE.md file at the top-level directory of this distribution.

rp_module_id="lr-mesen-s"
rp_module_desc="Nintendo SNES (Super Famicom), Game Boy, Game Boy Color & Super Game Boy Libretro Core"
rp_module_help="ROM Extensions: .sfc .smc .fig .swc .bs .gb .gbc\n\nCopy Your Game Boy ROMs to $romdir/gb\n\nCopy Your Game Boy Color ROMs to $romdir/gbc\n\nCopy Your SNES ROMs to $romdir/snes"
rp_module_licence="GPL3 https://raw.githubusercontent.com/SourMesen/Mesen-S/master/LICENSE"
rp_module_repo="git https://github.com/SourMesen/Mesen-S.git master"
rp_module_section="opt"

function sources_lr-messen-s() {
    gitPullOrClone
}

function build_lr-messen-s() {
    make clean
    make
    md_ret_require="$md_build/messen-s_libretro.so"
}

function install_lr-messen-s() {
    md_ret_files=('messen-s_libretro.so')
}

function configure_lr-mesen-s() {
  local system
  for system in "snes" "gb" "gbc"; do
    mkRomDir "$system"
    ensureSystemretroconfig "$system"
    addEmulator 0 "$md_id" "$system" "$md_inst/mesen-s_libretro.so"
    addSystem "$system"
  done
}