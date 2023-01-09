#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="duckstation"
rp_module_desc="DuckStation - Sony PlayStation Emulator"
rp_module_help="ROM Extensions: .bin .cue .chd .img\n\nCopy Your PSX ROMs to: $romdir/psx\n\nCopy the required BIOS file(s) ps-30a, ps-30e, ps-30j, scph5500.bin, scph5501.bin, and scph5502.bin to: $biosdir"
rp_module_licence="GPL3 https://raw.githubusercontent.com/stenzek/duckstation/master/LICENSE"
rp_module_section="main"
rp_module_repo="git https://github.com/stenzek/duckstation master"
rp_module_flags="!all arm aarch64 64bit"

function depends_duckstation() {
    local depends=(
        'cmake'
        'extra-cmake-modules'
        'libdrm'
        'ninja'
        'qt5-base'
        'qt5-tools'
        'sdl2'
        'xorg-xrandr'
    )
    getDepends "${depends[@]}"
}

function sources_duckstation() {
    gitPullOrClone
}

function build_duckstation() {
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DBUILD_TESTING=NO \
        -DUSE_DRMKMS=ON \
        -DUSE_WAYLAND=ON \
        -Wno-dev
    ninja -C build clean
    ninja -C build

    md_ret_require=(
        'build/bin/duckstation-nogui'
        'build/bin/duckstation-qt'
    )
}

function install_duckstation() {
    md_ret_files=(
        'build/bin/duckstation-nogui' 
        'build/bin/duckstation-qt'
        'build/bin/database'
        'build/bin/inputprofiles'
        'build/bin/resources'
        'build/bin/shaders'
        'build/bin/translations'
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
    ln -sf "$biosdir/${file}" "$md_conf_root/psx/bios/${file}"
  done

  addEmulator 1 "$md_id" "psx" "$md_inst/duckstation-nogui -fullscreen %ROM%"
  addEmulator 0 "$md_id-gui" "psx" "$md_inst/duckstation-qt -fullscreen %ROM%"
  addSystem "psx"
}
