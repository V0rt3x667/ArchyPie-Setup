#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE.md file at the top-level directory of this distribution.

rp_module_id="lr-craft"
rp_module_desc="Craft (MineCraft Clone) Libretro Core"
rp_module_help="ROM Extensions: N/A"
rp_module_licence="MIT https://raw.githubusercontent.com/libretro/Craft/master/LICENSE.md"
rp_module_repo="git https://github.com/libretro/craft master"
rp_module_section="exp"

function depends_craft() {
    local depends=('libglvnd')
    getDepends "${depends[@]}"
}

function sources_lr-craft() {
    gitPullOrClone
}

function build_lr-craft() {
    make clean
    make
    md_ret_require="$md_build/craft_libretro.so"
}

function install_lr-craft() {
    md_ret_files=(
        'craft_libretro.so'
        'LICENSE.md'
    )
}

function configure_lr-craft() {
    setConfigRoot "ports"

    addPort "$md_id" "craft" "Craft" "$md_inst/craft_libretro.so"

    defaultRAConfig "craft"
}
