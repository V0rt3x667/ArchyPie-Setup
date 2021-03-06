#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="sdltrs"
rp_module_desc="SDLTRS - Radio Shack TRS-80 Model 1, 3, 4 & 4P Emulator"
rp_module_help="ROM Extension: .dsk\n\nCopy your TRS-80 games to: $romdir/trs-80\n\nCopy the required BIOS file level2.rom, level3.rom, level4.rom or level4p.rom to $biosdir"
rp_module_section="exp"
rp_module_licence="BSD https://gitlab.com/jengun/sdltrs/-/raw/master/LICENSE"
rp_module_repo="git https://gitlab.com/jengun/sdltrs.git :_get_branch_sdltrs"
rp_module_flags=""

function _get_branch_sdltrs() {
    download https://gitlab.com/api/v4/projects/12284576/releases - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_sdltrs() {
    local depends=(
        'readline'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_sdltrs() {
    gitPullOrClone
}

function build_sdltrs() {
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -Wno-dev
    ninja -C build
    md_ret_require="$md_build/build/sdltrs"
}

function install_sdltrs() {
    ninja -C build install/strip
}

function configure_sdltrs() {
    local common_args
    mkRomDir "trs-80"

    common_args="-fullscreen -nomousepointer -showled"
    addEmulator 1 "$md_id-model1" "trs-80" "$md_inst/bin/sdltrs $common_args -m1 -romfile $biosdir/level2.rom -disk0 %ROM%"
    addEmulator 0 "$md_id-model3" "trs-80" "$md_inst/bin/sdltrs $common_args -m3 -romfile3 $biosdir/level3.rom -disk0 %ROM%"
    addEmulator 0 "$md_id-model4" "trs-80" "$md_inst/bin/sdltrs $common_args -m4 -romfile3 $biosdir/level4.rom -disk0 %ROM%"
    addEmulator 0 "$md_id-model4p" "trs-80" "$md_inst/bin/sdltrs $common_args -m4p -romfile4p $biosdir/level4p.rom -disk0 %ROM%"
    addSystem "trs-80"

    [[ "$md_mode" == "remove" ]] && return

    # Migrate settings from the previous version
    if [[ -h "$home/sdltrs.t8c" || -f "$home/sdltrs.t8c" ]]; then
       mv "$(readlink -f "$home/sdltrs.t8c")" "$home/.sdltrs.t8c"
    fi

    local config
    config="$(mktemp)"
    iniConfig "=" "" "$config"
    iniSet "statedir"   "$romdir/trs-80"
    iniSet "diskdir"    "$romdir/trs-80"
    iniSet "cassdir"    "$romdir/trs-80"
    iniSet "disksetdir" "$romdir/trs-80"
    iniSet "harddir"    "$romdir/trs-80"
    copyDefaultConfig "$config" "$md_conf_root/trs-80/sdltrs.t8c"

    moveConfigFile "$home/.sdltrs.t8c" "$md_conf_root/trs-80/sdltrs.t8c"
}
