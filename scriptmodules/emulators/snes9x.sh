#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="snes9x"
rp_module_desc="SNES9X: Nintendo SNES Emulator"
rp_module_help="ROM Extensions: .bin .fig .mgd .sfc .smc .swc .zip\n\nCopy SNES ROMs To: ${romdir}/snes"
rp_module_licence="NONCOM https://raw.githubusercontent.com/snes9xgit/snes9x/master/LICENSE"
rp_module_repo="git https://github.com/snes9xgit/snes9x :_get_branch_snes9x"
rp_module_section="main"
rp_module_flags=""

function _get_branch_snes9x() {
    download "https://api.github.com/repos/snes9xgit/${md_id}/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_snes9x() {
    local depends=(
        'alsa-lib'
        'boost-libs'
        'cmake'
        'libpulse'
        'libx11'
        'libxv'
        'meson'
        'minizip'
        'ninja'
        'portaudio'
        'sdl2_ttf'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_snes9x() {
    gitPullOrClone

    # Set Default Config Path(s)
    applyPatch "${md_data}/01_set_default_config_path.patch"
}

function build_snes9x() {
    cd gtk || exit

    meson setup -Dprefix="${md_inst}" -Dbuildtype="release" build
    meson compile -j"${__jobs}" -C build
    md_ret_require="${md_build}/gtk/build/${md_id}-gtk"
}

function install_snes9x() {
    ninja -C gtk/build install
    md_ret_require="${md_inst}/bin/${md_id}-gtk"
}

function configure_snes9x() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/snes/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "snes"
    fi

    addEmulator 1 "${md_id}" "snes" "${md_inst}/bin/${md_id}-gtk %ROM%"

    addSystem "snes"
}
