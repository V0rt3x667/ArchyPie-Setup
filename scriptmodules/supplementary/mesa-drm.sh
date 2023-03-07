#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="mesa-drm"
rp_module_desc="libdrm: Userspace Library For DRM"
rp_module_licence="MIT https://www.mesa3d.org/license.html"
rp_module_repo="git https://github.com/RetroPie/mesa-drm runcommand_debug"
rp_module_section="depends"
rp_module_flags=""

function depends_mesa-drm() {
    local depends=(
        'libdrm'
        'libpciaccess'
        'mesa'
        'meson'
        'ninja'
    )
    getDepends "${depends[@]}"
}

function sources_mesa-drm() {
    gitPullOrClone
}

function build_mesa-drm() {
    local params=()

    # For RPI, Disable All But VC4 Driver To Minimize Startup Delay
    isPlatform "rpi" && params+=(-Dintel=false -Dradeon=false \
                           -Damdgpu=false -Dexynos=false \
                           -Dnouveau=false -Dvmwgfx=false \
                           -Domap=false -Dfreedreno=false \
                           -Dtegra=false -Detnaviv=false -Dvc4=true)
    meson builddir --prefix="${md_inst}" "${params[@]}"
    ninja -C builddir

    md_ret_require="${md_build}/builddir/tests/modetest/modetest"
}

function install_mesa-drm() {
    md_ret_files=(
        builddir/libkms/libkms.so*
        builddir/tests/modetest/modetest
    )
}
