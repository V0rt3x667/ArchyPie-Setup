#!/bin/bash

################################################################################
# This file is part of the ArchyPie Project                                    #
#                                                                              #
# Please see the LICENSE file at the top-level directory of this distribution. #
################################################################################

rp_module_id="python-pysdl2"
rp_module_desc="PySDL2: Python SDL2 Wrapper"
rp_module_help="A Python wrapper for SDL2 (Required by joy2key)"
rp_module_licence="CC0 https://raw.githubusercontent.com/py-sdl/py-sdl2/refs/heads/master/doc/copying.rst"
rp_module_repo="git https://github.com/py-sdl/py-sdl2.git :_get_release_python-pysdl2"
rp_module_section="depends"
rp_module_flags="all"

function _get_release_python-pysdl2() {
    local release="0.9.17"
    echo "${release}"
}

function depends_python-pysdl2() {
    local depends=(
        'python-build'
        'python-installer'
        'python-setuptools'
        'python-wheel'
        'python'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_python-pysdl2() {
    gitPullOrClone
}

function build_python-pysdl2() {
    python -m build --wheel --no-isolation

    #md_ret_require="${md_build}/libSDL-1.2.so.$(_version_sdl12-compat short)"
}

function install_python-pysdl2() {
    python -m installer --destdir="${md_inst}" dist/*.whl
    install -Dm644 doc/copying.rst "${md_inst}/LICENSE"
}
