#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="duckstation"
rp_module_desc="DuckStation - Sony PlayStation Emulator"
rp_module_help="ROM Extensions: .bin .cue .chd .img\n\nCopy Your PSX ROMs to $romdir/psx\n\nCopy the required BIOS file(s) ps-30a, ps-30e, ps-30j, scph5500.bin, scph5501.bin, and scph5502.bin to the $biosdir"
rp_module_licence="GPL3 https://raw.githubusercontent.com/stenzek/duckstation/master/LICENSE"
rp_module_section="main"
rp_module_repo="git https://github.com/stenzek/duckstation master"
rp_module_flags="!all arm !armv6 aarch64 64bit"

function depends_duckstation() {
    getDepends cmake qt5-base sdl2 ninja xrandr qt5-tools libdrm
}

function sources_duckstation() {
    gitPullOrClone
}

function build_duckstation() {
    mkdir build
    cd build
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DBUILD_TESTING=NO \
        -DUSE_DRMKMS=ON \
        -DUSE_WAYLAND=ON \
        -GNinja
    ninja
    md_ret_require=(
        '$md_build/build/duckstation-nogui'
        '$md_build/build/duckstation-qt'
    )
}

function install_duckstation() {
    cd build
    md_ret_files=(
        'duckstation-nogui' 
        'duckstation-qt'
        'bin/database'
        'bin/inputprofiles'
        'bin/resources'
        'bin/shaders'
        'bin/translations'
    )
}

function configure_duckstation() {
  mkRomDir "psx"

  moveConfigDir "$home/.local/share/duckstation" "$md_conf_root/psx"
  mkUserDir "$md_conf_root/psx/bios"

  local bios
  bios=(
    'ps-30a'
    'ps-30e'
    'ps-30j'
    'scph5500.bin'
    'scph5501.bin'
    'scph5502.bin'
  )

  for file in "${bios[@]}"; do
    ln -sf "$biosdir/$file" "$md_conf_root/psx/bios/$file"
  done

  addEmulator 1 "$md_id" "psx" "$md_inst/duckstation-nogui -fullscreen %ROM%"
  addEmulator 0 "$md_id-gui" "psx" "$md_inst/duckstation-qt -fullscreen %ROM%"
  addSystem "psx"
}
