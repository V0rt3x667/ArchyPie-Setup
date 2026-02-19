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
    local chroot=$HOME/Projects/chroot
    arch-nspawn "$chroot"/root pacman -Syu
    makechrootpkg -c -r "$chroot"
}

## @fn pacmanPKGBuild()
## @param package(s) to build & install
## @brief build & install packages from PKGBUILD files
function buildPKG() {
    # local builddir="/tmp/pkgs"
    # local pkg

    # for pkg in "$@"; do
    #     su "$__user" --session-command 'cd '"$scriptdir/packages/$pkg"' && \
    #         if [[ ! -d '"$builddir/$pkg"' ]]; then
    #             mkdir -p '"$builddir/${pkg}"'
    #         fi
    #         BUILDDIR='"$builddir/$pkg"' \
    #         PKGDEST='"$builddir/$pkg"' \
    #         SRCDEST='"$builddir/$pkg"' \
    #         SRCPKGDEST='"$builddir/$pkg"' \
    #         PACKAGER="archrgs.project <archrgs.project@gmail.com>" \
    #         makepkg -crsi --noconfirm'
    # done

    local builddir="./builddir"
    local pkg=$1
    local key="B73B4ACF44D6491CE94E52223D27922F2EC6B6AE"

    pacman-key --recv-keys $key && pacman-key --lsign-key $key

    for pkg in "$@"; do
        su "$USER" --session-command 'cd '"./packages/$pkg"' && \
            if [[ ! -d '"$builddir/$pkg"' ]]; then
                mkdir -p '"$builddir/$pkg"'
            fi
            BUILDDIR='"$builddir/$pkg"' \
            PKGDEST='"$builddir/$pkg"' \
            SRCDEST='"$builddir/$pkg"' \
            SRCPKGDEST='"$builddir/$pkg"' \
            PACKAGER='"archypieproject <archypieproject@protonmail.com>"' \
            GPGKEY='"$key"' \
            makepkg -crsi --sign'
    done
}

createChroot && buildPKG "$1"

