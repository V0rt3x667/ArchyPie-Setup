#!/bin/bash

################################################################################
# This file is part of the ArchyPie Project                                    #
#                                                                              #
# Please see the LICENSE file at the top-level directory of this distribution. #
################################################################################

rp_module_id="sfml"
rp_module_desc="SFML: A simple, fast, cross-platform, & object-oriented multimedia API (KMSDRM Enabled)"
rp_module_licence="ZLIB https://raw.githubusercontent.com/SFML/SFML/refs/heads/master/license.md"
rp_module_section="depends"
rp_module_flags="!all kms"

function get_pkg_ver_sfml() {
    echo "2.6.2"
}

function remove_old_sfml() {
    # Remove our sfml-arpie package
    hasPackage sfml-arpie && pacmanRemove sfml-arpie
}

function install_sfml() {
    remove_old_sfml

    pacmanPKGBuild sfml-arpie
    if [[ "${?}" -ne 0 ]]; then
        md_ret_errors+=("Failed to install ${md_id} !")
        exit
    fi
    return 0
}

function remove_sfml() {
    pacmanRemove sfml-arpie
}
