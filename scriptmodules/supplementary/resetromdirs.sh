#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="resetromdirs"
rp_module_desc="Reset Ownership & Permissions of the ArchyPie ROM, BIOS & Data Directories"
rp_module_section="config"

function gui_resetromdirs() {
    printHeading "Resetting $romdir Ownership & Permissions"
    mkUserDir "$romdir"
    mkUserDir "$biosdir"
    mkUserDir "$datdir"
    chown -R "$user:$user" "$romdir"
    chown -R "$user:$user" "$biosdir"
    chown -R "$user:$user" "$datdir"
    chmod -R ug+rwx "$romdir"
    chmod -R ug+rwx "$biosdir"
    chmod -R ug+rwx "$datdir"
}
