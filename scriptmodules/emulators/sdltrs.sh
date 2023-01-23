#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="sdltrs"
rp_module_desc="SDLTRS: Radio Shack TRS-80 Model 1, 3, 4 & 4P Emulator"
rp_module_help="ROM Extension: .dsk\n\nCopy TRS-80 Games To: ${romdir}/trs-80\n\nCopy BIOS Files:\nlevel2.rom\nlevel3.rom\nlevel4.rom\nlevel4p.rom\n\nTo: ${biosdir}/trs-80"
rp_module_section="exp"
rp_module_licence="BSD https://gitlab.com/jengun/sdltrs/-/raw/master/LICENSE"
rp_module_repo="git https://gitlab.com/jengun/sdltrs :_get_branch_sdltrs"
rp_module_flags=""

function _get_branch_sdltrs() {
    download "https://gitlab.com/api/v4/projects/12284576/releases" - | grep -m 1 tag_name | cut -d\" -f4
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

    # Set Default Config Path(s)
    sed -e "s|/.sdltrs.t8c\"|/ArchyPie/configs/${md_id}/sdltrs.t8c\"|g" -i "${md_build}/src/trs_sdl_interface.c"
}

function build_sdltrs() {
    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/${md_id}"
}

function install_sdltrs() {
    ninja -C build install/strip
    md_ret_require="${md_inst}/bin/${md_id}"
}

function configure_sdltrs() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/trs-80/${md_id}/"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "trs-80"
        mkUserDir "${biosdir}/trs-80"

        # Create Default Config File
        local config
        config="$(mktemp)"
        iniConfig "=" "" "${config}"

        iniSet "statedir"   "${romdir}/trs-80"
        iniSet "diskdir"    "${romdir}/trs-80"
        iniSet "cassdir"    "${romdir}/trs-80"
        iniSet "disksetdir" "${romdir}/trs-80"
        iniSet "harddir"    "${romdir}/trs-80"
        copyDefaultConfig "${config}" "${md_conf_root}/trs-80/${md_id}/sdltrs.t8c"
    fi

    local params=(
        '-fullscreen'
        '-nomousepointer'
        '-showled'
    )

    addEmulator 1 "${md_id}-model1" "trs-80" "${md_inst}/bin/sdltrs ${params[*]} -m1 -romfile ${biosdir}/trs-80/level2.rom -disk0 %ROM%"
    addEmulator 0 "${md_id}-model3" "trs-80" "${md_inst}/bin/sdltrs ${params[*]} -m3 -romfile3 ${biosdir}/trs-80/level3.rom -disk0 %ROM%"
    addEmulator 0 "${md_id}-model4" "trs-80" "${md_inst}/bin/sdltrs ${params[*]} -m4 -romfile3 ${biosdir}/trs-80/level4.rom -disk0 %ROM%"
    addEmulator 0 "${md_id}-model4p" "trs-80" "${md_inst}/bin/sdltrs ${params[*]} -m4p -romfile4p ${biosdir}/trs-80/level4p.rom -disk0 %ROM%"

    addSystem "trs-80"
}
