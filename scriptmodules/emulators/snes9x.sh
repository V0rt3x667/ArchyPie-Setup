#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="snes9x"
rp_module_desc="SNES9X: Nintendo SNES Emulator"
rp_module_help="ROM Extensions: .bin .fig .mgd .sfc .smc .swc .zip\n\nCopy SNES ROMs To: ${romdir}/snes"
rp_module_licence="NONCOM https://raw.githubusercontent.com/snes9xgit/snes9x/master/LICENSE"
rp_module_repo="git https://github.com/snes9xgit/snes9x master" #:_get_branch_snes9x Not able To Build From Release Tag 1.62.3
rp_module_section="main"
rp_module_flags=""

function _get_branch_snes9x() {
    download "https://api.github.com/repos/snes9xgit/snes9x/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_snes9x() {
    local depends=(
        'alsa-lib'
        'cairo'
        'clang'
        'cmake'
        'glslang'
        'gtkmm3'
        'libepoxy'
        'libpng'
        'libpulse'
        'libx11'
        'libxv'
        'lld'
        'minizip'
        'ninja'
        'portaudio'
        'python'
        'sdl2'
        'zlib'
    )
    isPlatform "x11" && depends+=('libxrandr')
    getDepends "${depends[@]}"
}

function sources_snes9x() {
    gitPullOrClone

    # Set Default Config Path(s)
    applyPatch "${md_data}/01_set_default_config_path.patch"
}

function build_snes9x() {
    cmake . \
        -B"build" \
        -G"Ninja" \
        -S"gtk" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_EXE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_MODULE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_SHARED_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DUSE_OSS="OFF" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/${md_id}-gtk"
}

function install_snes9x() {
    ninja -C build install/strip
    md_ret_require="${md_inst}/bin/${md_id}-gtk"
}

function configure_snes9x() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/snes/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "snes"

        # Create Snes9x Directories
        local dirs=(
            'cheats'
            'patchs'
            'saves'
            'SRAM'
        )
        for dir in "${dirs[@]}"; do
            mkUserDir "${md_conf_root}/snes/${md_id}/${dir}"
        done

        # Set Default Config File
        local config
        config="$(mktemp)"
        iniConfig " = " "" "${config}"

        echo "[Display]" > "${config}"
        iniSet "FullscreenOnOpen" "true"
        echo "[Files]" >> "${config}"
        iniSet "CheatDirectory"     "${md_conf_root}/snes/${md_id}/cheats"
        iniSet "PatchDirectory"     "${md_conf_root}/snes/${md_id}/patchs"
        iniSet "SRAMDirectory"      "${md_conf_root}/snes/${md_id}/SRAM"
        iniSet "SaveStateDirectory" "${md_conf_root}/snes/${md_id}/saves"

        copyDefaultConfig "${config}" "${md_conf_root}/snes/${md_id}/snes9x.conf"
        rm "${config}"

    fi

    addEmulator 1 "${md_id}" "snes" "${md_inst}/bin/${md_id}-gtk %ROM%"

    addSystem "snes"
}
