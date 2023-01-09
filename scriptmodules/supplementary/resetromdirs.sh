#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="resetromdirs"
rp_module_desc="Reset Ownership & Permissions of the ArchyPie ROM & BIOS Directories"
rp_module_section="config"

function gui_resetromdirs() {
    printHeading "Resetting $romdir Ownership & Permissions"

    mkUserDir "$romdir"
    mkUserDir "$biosdir"

    chown -R "${user}:${user}" "$romdir"
    chown -R "${user}:${user}" "$biosdir"

    chmod -R ug+rwx "$romdir"
    chmod -R ug+rwx "$biosdir"
}
