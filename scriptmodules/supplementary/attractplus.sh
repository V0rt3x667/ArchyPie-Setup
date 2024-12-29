#!/bin/bash

################################################################################
# This file is part of the ArchyPie Project                                    #
#                                                                              #
# Please see the LICENSE file at the top-level directory of this distribution. #
################################################################################

rp_module_id="attractplus"
rp_module_desc="Attract-Mode Plus: Emulator Frontend"
rp_module_licence="GPL3 https://raw.githubusercontent.com/oomek/attractplus/master/License.txt"
rp_module_repo="git https://github.com/oomek/attractplus :_get_release_attractplus"
rp_module_section="exp"
rp_module_flags="frontend sfml"

function _get_release_attractplus() {
    # Current release
    local release="3.0.9"

    echo "${release}"
}

function _get_configdir_attractplus() {
    _get_configdir_attract
}

function _add_system_attractplus() {
    _add_system_attract
}

function _del_system_attractplus() {
    _del_system_attract
}

function _add_rom_attractplus() {
    _add_rom_attract
}

function depends_attractplus() {
    depends_attract
}

function sources_attractmodeplus() {
    gitPullOrClone

    # Set default config path(s)
    sed -e "s|/.attract|/opt/archypie/configs/all/${md_id}|g" -i "${md_build}/src/fe_settings.cpp"
}

function build_attractplus() {
    build_attract
}

function install_attractplus() {
    install_attract
}

function remove_attractplus() {
    remove_attract
}

function configure_attractplus() {
    configure_attract
}
