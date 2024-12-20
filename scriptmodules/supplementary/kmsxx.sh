#!/bin/bash

################################################################################
# This file is part of the ArchyPie Project                                    #
#                                                                              #
# Please see the LICENSE file at the top-level directory of this distribution. #
################################################################################

rp_module_id="kmsxx"
rp_module_desc="Library & Utilities for Linux Kernel Mode Setting"
rp_module_licence="MPL2 https://raw.githubusercontent.com/cmitu/kmsxx/master/LICENSE"
rp_module_repo="git https://github.com/cmitu/kmsxx retropie"
rp_module_section="depends"
rp_module_flags=""

function depends_kmsxx() {
    local depends=(
        'fmt'
        'libdrm'
        'libevdev'
        'meson'
        'ninja'
        'pkgconf'
    )
    getDepends "${depends[@]}"
}

function sources_kmsxx() {
    gitPullOrClone
}

function build_kmsxx() {
    meson setup build \
        -Dbuildtype="release" \
        -Ddefault_library="static" \
        -Dkmscube="false" \
        -Domap="disabled" \
        -Dprefix="${md_inst}" \
        -Dpykms="disabled"
    ninja -C build clean
    ninja -C build

    md_ret_require="${md_build}/build/utils/kmsprint-rp"
}

function install_kmsxx() {
    md_ret_files=(
        build/utils/kmsprint-rp
        build/utils/kmsprint
        build/utils/kmsview
        build/utils/kmsblank
        build/utils/fbtest
    )
}
