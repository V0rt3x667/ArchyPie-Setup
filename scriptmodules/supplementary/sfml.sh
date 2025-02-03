#!/bin/bash

################################################################################
# This file is part of the ArchyPie Project                                    #
#                                                                              #
# Please see the LICENSE file at the top-level directory of this distribution. #
################################################################################

rp_module_id="sfml"
rp_module_desc="SFML: An Object-oriented Multimedia API (KMSDRM Enabled)"
rp_module_licence="ZLIB https://raw.githubusercontent.com/SFML/SFML/refs/heads/master/license.md"
rp_module_repo="git https://github.com/SFML/SFML.git :_get_release_sfml"
rp_module_section="depends"
rp_module_flags="!all kms"

function _get_release_sfml() {
    local release="2.6.2"
    echo "${release}"
}

function depends_sfml() {
    local depends=(
        'cmake'
        'doxygen'
        'freetype2'
        'glew'
        'libsndfile'
        'libx11'
        'libxcursor'
        'libxrandr'
        'mesa'
        'mold'
        'ninja'
        'openal'
    )
    getDepends "${depends[@]}"
}

function sources_sfml() {
    gitPullOrClone
}

function build_sfml() {
    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_LINKER_TYPE="MOLD" \
        -DSFML_BUILD_DOC="OFF" \
        -DSFML_BUILD_EXAMPLES="OFF" \
        -DSFML_INSTALL_PKGCONFIG_FILES="OFF" \
        -DSFML_USE_DRM="ON" \
        -DSFML_USE_SYSTEM_DEPS="ON" \
        -Wno-dev
    ninja -C build clean
    ninja -C build

    md_ret_require="${md_build}/libsfml-system.so.$(_release_sfml)"
}

function install_sfml() {
    ninja -C build install/strip

    install -Dm644 "license.md" "${md_inst}/LICENSE"
}
