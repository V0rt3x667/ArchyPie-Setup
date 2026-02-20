#!/usr/bin/env bash

#     ________   ______    ______   ___   ___   __  __            ______   ________  ______      
#    /_______/\ /_____/\  /_____/\ /__/\ /__/\ /_/\/_/\          /_____/\ /_______/\/_____/\     
#    \::: _  \ \\:::_ \ \ \:::__\/ \::\ \\  \ \\ \ \ \ \  _______\:::_ \ \\__.::._\/\::::_\/_    
#     \::(_)  \ \\:(_) ) )_\:\ \  __\::\/_\ .\ \\:\_\ \ \/______/\\:(_) \ \  \::\ \  \:\/___/\   
#      \:: __  \ \\: __ `\ \\:\ \/_/\\:: ___::\ \\::::_\/\__::::\/ \: ___\/  _\::\ \__\::___\/_  
#       \:.\ \  \ \\ \ `\ \ \\:\_\ \ \\: \ \\::\ \ \::\ \           \ \ \   /__\::\__/\\:\____/\ 
#        \__\/\__\/ \_\/ \_\/ \_____\/ \__\/ \::\/  \__\/            \_\/   \________\/ \_____\/ 
#
#    This file is part of the ArchyPie Project.
#
#    Please see the LICENSE file at the top-level directory of this distribution.

function createChroot() {
    local chrootdir="$HOME/packages/chroot"
    local key="B73B4ACF44D6491CE94E52223D27922F2EC6B6AE"

    sudo pacman -S devtools --needed --noconfirm

    if [[ ! -d "$chrootdir" ]]; then
        mkdir -p "$chrootdir"
    fi

    sudo mkarchroot "$chrootdir/root" base-devel

    sudo arch-nspawn "$chrootdir/root" -- sudo pacman -Syyu && sudo pacman-key --recv-keys "$key" && sudo pacman-key --lsign-key "$key"
}

## @fn buildPKG()
## @param package(s) to build & install
## @brief build & install packages from PKGBUILD files
function buildPKG() {
    local builddir="$HOME/packages/chroot"
    local pkgdir="$HOME/packages/pkgbuilds"
    local pkg=$1
    local key="3D27922F2EC6B6AE"

    if [[ ! -d "$pkgdir" ]]; then
        mkdir -p "$pkgdir"
    fi

    cd "$pkgdir/$pkg" || exit
    makechrootpkg -c -r "$builddir" -U "$USER" -- \
        BUILDDIR="./" \
        PKGDEST="./" \
        SRCDEST="./" \
        SRCPKGDEST="./" \
        PACKAGER="archypieproject <archypieproject@protonmail.com>" \
        GPGKEY="$key"
}

createChroot && buildPKG "$1"

