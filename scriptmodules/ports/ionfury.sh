#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="ionfury"
rp_module_desc="Ion Fury: FPS Game Based on the EDuke32 Source Port"
rp_module_help="Copy fury.def, fury.grp And fury.grpinfo To:\n${romdir}/ports/ionfury"
rp_module_licence="GPL2 https://voidpoint.io/terminx/eduke32/-/raw/master/package/common/gpl-2.0.txt?inline=false"
rp_module_repo="git https://voidpoint.io/terminx/eduke32.git master"
rp_module_section="exp"

function depends_ionfury() {
    depends_eduke32
}

function sources_ionfury() {
    sources_eduke32
}

function build_ionfury() {
    build_eduke32
}

function install_ionfury() {
    install_eduke32
}

function configure_ionfury() {
    configure_eduke32
}
