#!/bin/bash

################################################################################
# This file is part of the ArchyPie Project                                    #
#                                                                              #
# Please see the LICENSE file at the top-level directory of this distribution. #
################################################################################

rp_module_id="python-uinput"
rp_module_desc="Python-uinput: Python Linux uinput Kernel Module Interface"
rp_module_help="A Python interface to the Linux uinput kernel module (Required by joy2key)"
rp_module_licence="GPL3 https://raw.githubusercontent.com/pyinput/python-uinput/refs/heads/master/COPYING"
rp_module_repo="git https://github.com/pyinput/python-uinput.git :_get_release_python-uinput"
rp_module_section="depends"
rp_module_flags="all"

function _get_release_python-uinput() {
    local release=="1.0.1"
    echo "${release}"
}

function depends_python-uinput() {
    local depends=(
        'python-build'
        'python-installer'
        'python-setuptools'
        'python-wheel'
        'python'
        'systemd-libs'
    )
    getDepends "${depends[@]}"
}

function sources_python-uinput() {
    gitPullOrClone
}

function build_python-uinput() {
    python -m build --wheel --no-isolation

    #md_ret_require="${md_build}/libSDL-1.2.so.$(_version_sdl12-compat short)"
}

function install_python-uinput() {
    python -m installer --destdir="${md_inst}" dist/*.whl
}
