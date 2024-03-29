#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="ionfury"
rp_module_desc="Ion Fury: FPS Game Based On The EDuke32 Source Port"
rp_module_help="For Ion Fury Copy fury.grp & fury.grpinfo To: ${romdir}/ports/ionfury/fury\n\nFor Ion Fury: Aftershock Rename fury.grp To aftershock.grp Copy aftershock.grp & fury.grpinfo To: ${romdir}/ports/ionfury/aftershock"
rp_module_licence="GPL2 https://voidpoint.io/terminx/eduke32/-/raw/master/package/common/gpl-2.0.txt"
rp_module_repo="git https://voidpoint.io/terminx/eduke32 master"
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
