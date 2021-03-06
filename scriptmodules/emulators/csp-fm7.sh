#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="csp-fm7"
rp_module_desc="CSP-FM7 - Fujitsu FM-8, FM-7, 77AV, 77AV40, 77AV40EX & 77AV40SX Emulator"
rp_module_help="ROM Extensions: .d77 .t77 .d88 .2d \n\nCopy Your FM-7 Games to: $romdir/fm7\n\nCopy Your BIOS File(s) to: $biosdir/fm7\n\n  DICROM.ROM\n  EXTSUB.ROM\n  FBASIC30.ROM\n  INITIATE.ROM\n  KANJI1.ROM\n  KANJI2.ROM\n  SUBSYS_A.ROM\n  SUBSYS_B.ROM\n  SUBSYSCG.ROM\n  SUBSYS_C.ROM\n  fddseek.wav\n  relayoff.wav\n  relay_on.wav"
rp_module_licence="GPL2 https://raw.githubusercontent.com/Artanejp/common_source_project-fm7/master/README.en.md"
rp_module_repo="git https://github.com/Artanejp/common_source_project-fm7 master"
rp_module_section="exp"
rp_module_flags="!all 64bit"

function depends_csp-fm7() {
    local depends=(
        'cmake'
        'ffmpeg4.4'
        'ninja'
        'qt6-base'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_csp-fm7() {
    gitPullOrClone
    local strings=(
        'include(config_fm16)'
        'include(config_fmr)'
        'include(config_fmtowns)'
        'include(config_casio)'
        'include(config_msx)'
        'include(config_mz80_700)'
        'include(config_pc6001)'
        'include(config_pc8801)'
        'include(config_pc9801)'
        'include(config_x1)'
        'include(config_necmisc)'
        'include(config_toshiba)'
        'include(config_epson)'
        'include(config_sega)'
        'include(config_misccom)'
        'include(config_singleboards)'
    )
    for string in "${strings[@]}"; do
        sed -e "s|$string|#$string|g" -i "$md_build/source/CMakeLists.txt"
    done
}

function build_csp-fm7() {
    cmake . \
        -Ssource \
        -Bsource/build \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS} -Wl,-rpath='$md_inst/lib'" \
        -DLIBAV_INCLUDE_DIR="/usr/include/ffmpeg4.4" \
        -DUSE_MOVIE_LOADER=OFF \
        -DUSE_MOVIE_SAVER=OFF \
        -DCSP_BUILD_WITH_CXX20=ON \
        -DUSE_QT_6=ON \
        -DUSE_SDL2=ON \
        -Wno-dev
    ninja -C source/build clean
    ninja -C source/build

    md_ret_require=(
        "source/build/emufm8"
        "source/build/emufm7"
        "source/build/emufm77av"
        "source/build/emufm77av40"
        "source/build/emufm77av40ex"
        "source/build/emufm77av40sx"
    )
}

function install_csp-fm7() {
    ninja -C source/build install/strip
}

function configure_csp-fm7() {
    mkRomDir "fm7"
    mkUserDir "$biosdir/fm7"

    addEmulator 0 "csp-fm8" "fm7" "$md_inst/bin/emufm8 %ROM%"
    addEmulator 1 "csp-fm7" "fm7" "$md_inst/bin/emufm7 %ROM%"
    addEmulator 0 "csp-fm77av" "fm7" "$md_inst/bin/emufm77av %ROM%"
    addEmulator 0 "csp-fm77av40" "fm7" "$md_inst/bin/emufm77av40 %ROM%"
    addEmulator 0 "csp-fm77av40ex" "fm7" "$md_inst/bin/emufm77av40ex %ROM%"
    addEmulator 0 "csp-fm77av40sx" "fm7" "$md_inst/bin/emufm77av40sx %ROM%"
    addSystem "fm7"

    [[ "$md_mode" == "remove" ]] && return

    moveConfigDir "$home/.config/CommonSourceCodeProject" "$md_conf_root/fm7"
    moveConfigDir "$home/CommonSourceCodeProject" "$md_conf_root/fm7"

    local dirs
    dirs=(
        'emufm8'
        'emufm7'
        'emufm77av'
        'emufm77av40'
        'emufm77av40ex'
        'emufm77av40sx'
    )
    for dir in "${dirs[@]}"; do
        mkUserDir "$md_conf_root/fm7/$dir"
        ln -snf "$md_conf_root/fm7/$dir" "$biosdir/fm7/$dir"
    done
}
