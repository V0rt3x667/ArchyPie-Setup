#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="srb2kart"
rp_module_desc="Sonic Robo Blast 2 Kart - Kart Racing Mod Based on Sonic Robo Blast 2"
rp_module_licence="GPL2 https://raw.githubusercontent.com/STJr/Kart-Public/master/LICENSE"
rp_module_repo="git https://github.com/STJr/Kart-Public.git :_get_branch_srb2kart"
rp_module_section="opt"

function _get_branch_srb2kart() {
    download https://api.github.com/repos/STJr/Kart-Public/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_srb2kart() {
    local depends=(cmake sdl2 sdl2_mixer libgme libpng)
    isPlatform x86 && depends+=(yasm)

    getDepends "${depends[@]}"
}

function sources_srb2kart() {
    gitPullOrClone

    local ver
    ver="$(_get_branch_srb2kart)"
    downloadAndExtract "https://github.com/STJr/Kart-Public/releases/download/$ver/srb2kart-${ver//./}-Installer.exe" "$md_build/assets/installer" 
    cd "$md_build/assets/installer"
    rm *.bat *.dat *.dll *.exe *.txt
}

function build_srb2kart() {
    mkdir build
    cd build
    cmake .. \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst"
    ninja
    md_ret_require="$md_build/build/bin/srb2kart"
}

function install_srb2kart() {
    ninja -C build install
    # copy and dereference, so we get a srb2kart binary rather than a symlink to srb2kart-1.3 version
    #cp -L "$md_inst/srb2kart" "$md_inst/srb2kart"
}

function configure_srb2kart() {
  addPort "$md_id" "srb2kart" "Sonic Robo Blast 2 Kart" "pushd $md_inst; srb2kart; popd"

  moveConfigDir "$home/.srb2kart" "$md_conf_root/srb2kart"
}
