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

rp_module_id="attractmodeplus"
rp_module_desc="Attract-Mode Plus: Emulator Frontend"
rp_module_licence="GPL3 https://raw.githubusercontent.com/oomek/attractplus/master/License.txt"
rp_module_repo="git https://github.com/oomek/attractplus : 3.2.2"
rp_module_section="exp"
rp_module_flags="frontend sfml"

function _get_configdir_attractmodeplus() {
    _get_configdir_attractmode
}

function _add_system_attractmodeplus() {
    _add_system_attractmode
}

function _del_system_attractmodeplus() {
    _del_system_attractmode
}

function _add_rom_attractmodeplus() {
    _add_rom_attractmode
}

function depends_attractmodeplus() {
    depends_attractmode
}

function sources_attractmodeplus() {
    gitPullOrClone

    # Set default config path(s)
    sed -e "s|/.attract|/opt/archypie/configs/all/${md_id}|g" -i "${md_build}/src/fe_settings.cpp"
}

function build_attractmodeplus() {
    build_attractmode
}

function install_attractmodeplus() {
    install_attractmode
}

function remove_attractmodeplus() {
    remove_attractmode
}

function configure_attractmodeplus() {
    configure_attractmode
}

