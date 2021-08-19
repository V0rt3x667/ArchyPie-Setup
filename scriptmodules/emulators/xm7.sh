#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="xm7"
rp_module_desc="XM7 - Fujitsu FM-7 Series Emulator"
rp_module_help="ROM Extensions: .d77 .t77 .d88 .2d \n\nCopy your FM-7 games to to $romdir/xm7\n\nCopy bios files DICROM.ROM, EXTSUB.ROM, FBASIC30.ROM, INITIATE.ROM, KANJI1.ROM, KANJI2.ROM, SUBSYS_A.ROM, SUBSYS_B.ROM, SUBSYSCG.ROM, SUBSYS_C.ROM, fddseek.wav, relayoff.wav and relay_on.wav to $biosdir/xm7"
rp_module_licence="NONCOM https://raw.githubusercontent.com/nakatamaho/XM7-for-SDL/master/Doc/mess/license.txt"
rp_module_repo="git https://github.com/nakatamaho/XM7-for-SDL.git master"
rp_module_section="exp"
rp_module_flags="!mali !kms"

function depends_xm7() {
    local depends=(
        'cmake'
        'fontconfig'
        'freetype2'
        'gawk'
        'gcc10'
        'imagemagick'
        'libjpeg'
        'libpng'
        'libtool'
        'libx11'
        'libxinerama'
        'sdl'
        'sdl_mixer'
    )
    getDepends "${depends[@]}"
}

function sources_xm7() {
    gitPullOrClone
    # needs libx11 to link
    applyPatch "$md_data/01_fix_build.diff"

    mkdir -p "$md_build/agar"
    downloadAndExtract "http://stable.hypertriton.com/agar/agar-1.5.0.tar.gz" "$md_build/agar" --strip-components 1
    # _BSD_SOURCE is deprecated and will throw an error during configure
    sed -i "s/_BSD_SOURCE/_DEFAULT_SOURCE/g" "$md_build/agar/configure"
}

function _build_uim_xm7() {
    pacmanPkg archy-uim
}

function _build_otf-takao_xm7() {
    pacmanPkg otf-takao
}

function _build_libagar_xm7() {
    cd agar
    # create fake freetype-config to use pkg-config due to freetype-config being removed in recent versions
    mkdir -p bin
    cat > bin/freetype-config << _EOF_
#!/bin/bash
arg="\$1"
[[ "\$arg" == "--version" ]] && arg="--modversion"
pkg-config freetype2 \$arg
_EOF_
    chmod +x "bin/freetype-config"

    ./configure \
        --disable-shared \
        --prefix="$md_build/libagar" \
        --enable-freetype="$md_build/agar"
    make -j1 depend all install
}

function build_xm7() {
    _build_uim_xm7
    _build_otf-takao_xm7
    _build_libagar_xm7

    mkdir $md_build/linux-sdl/build
    cd $md_build/linux-sdl/build
    export CC="gcc-10" CXX="g++-10" 
    cmake .. \
        -DCMAKE_CXX_FLAGS="-DSHAREDIR='\"${md_inst}/share/xm7\"'" \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_TYPE=Release \
        -DUSE_OPENCL=No \
        -DUSE_OPENGL=No \
        -DWITH_LIBAGAR_PREFIX="$md_build/libagar" \
        -DWITH_AGAR_STATIC=yes \
        -Wno-dev
    make
    md_ret_require="$md_build/linux-sdl/build/sdl/xm7"
}

function install_xm7() {
    cd linux-sdl/build
    make install
}

function configure_xm7() {
    mkRomDir "fm7"

    addEmulator 1 "$md_id" "fm7" "$md_inst/bin/xm7 %ROM%"
    addSystem "fm7"

    [[ "$md_mode" == "remove" ]] && return

    moveConfigDir "$home/.xm7" "$md_conf_root/fm7"

    mkUserDir "$biosdir/fm7"

    local bios
    for bios in DICROM.ROM EXTSUB.ROM FBASIC30.ROM INITIATE.ROM KANJI1.ROM KANJI2.ROM SUBSYS_A.ROM SUBSYS_B.ROM SUBSYSCG.ROM SUBSYS_C.ROM fddseek.wav relayoff.wav relay_on.wav; do
        ln -sf "$biosdir/fm7/$bios" "$md_conf_root/fm7/$bios"
    done
}
