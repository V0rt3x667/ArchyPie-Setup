#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="mysticmine"
rp_module_desc="Mystic Mine - Rail Game for Up to Six Players on One Keyboard"
rp_module_licence="MIT https://raw.githubusercontent.com/dewitters/MysticMine/master/LICENSE.txt"
rp_module_repo="git https://github.com/dewitters/MysticMine.git master"
rp_module_section="exp"
rp_module_flags="!all x86 64bit"

function depends_mysticmine() {
    local package=(
        'https://archive.archlinux.org/packages/p/python2-numpy/python2-numpy-1.16.6-1-x86_64.pkg.tar.zst'
        'https://archive.archlinux.org/packages/p/python2-pygame/python2-pygame-1.9.5-1-x86_64.pkg.tar.xz'
        'https://archive.archlinux.org/packages/p/pyrex/pyrex-0.9.9-5-any.pkg.tar.xz'
    )
    for p in "${package[@]}"; do
        pacman -U "$p" --noconfirm
    done
}

function sources_mysticmine() {
    gitPullOrClone
}

function build_mysticmine() {
    make
}

function install_mysticmine() {
    python2 setup.py install --prefix "$md_inst"
}

function configure_mysticmine() {
    addPort "$md_id" "mysticmine" "MysticMine" "pushd $md_inst; PYTHONPATH=$PYTHONPATH:${md_inst}/lib/python2.7/site-packages ./bin/MysticMine; popd"
}
