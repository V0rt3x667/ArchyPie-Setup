#!/bin/bash

################################################################################
# This file is part of the ArchyPie Project                                    #
#                                                                              #
# Please see the LICENSE file at the top-level directory of this distribution. #
################################################################################

rp_module_id="sdl12-compat"
rp_module_desc="SDL1.2 compatibility layer that uses SDL2 under the hood"
rp_module_help="Provides a binary and source compatible API for programs written against SDL 1.2, but it uses SDL 2.0 behind the scenes"
rp_module_licence="ZLIB https://raw.githubusercontent.com/libsdl-org/sdl12-compat/main/LICENSE.txt"
rp_module_repo="git https://github.com/libsdl-org/sdl12-compat :_version_sdl12-compat"
rp_module_section="depends"
rp_module_flags="!x11"

function _version_sdl12-compat() {
    local ver="1.2.68"
    if [[ "${1}" == "short" ]]; then
        echo ${ver}
    else
        echo "release-${ver}"
    fi
}

function depend_sdl12-compat() {
    getDepends sdl12-compat
}

#function sources_sdl12-compat() {
#    gitPullOrClone
#}

#function build_sdl12-compat() {
#    cmake -DSDL12TESTS=OFF -DSDL12DEVEL=OFF .
#    make
#    md_ret_require="$md_build/libSDL-1.2.so.$(_version_sdl12-compat short)"
#}

#function install_sdl12-compat() {
#    md_ret_files=(
#        libSDL-1.2.so."$(_version_sdl12-compat short)"
#        README.md
#        LICENSE.txt
#    )
#}

#function configure_sdl12-compat() {
#    ldconfig -nN "$md_inst"
#}
