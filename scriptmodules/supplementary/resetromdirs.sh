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

rp_module_id="resetromdirs"
rp_module_desc="Reset Ownership & Permissions of the ArchyPie ROM & BIOS Directories"
rp_module_section="config"

function gui_resetromdirs() {
    printHeading "Resetting $romdir ownership & permissions"
    mkUserDir "$romdir"
    mkUserDir "$biosdir"
    chown -R "$__user":"$__group" "$romdir"
    chown -R "$__user":"$__group" "$biosdir"
    chmod -R ug+rwX "$romdir"
    chmod -R ug+rwX "$biosdir"
}

