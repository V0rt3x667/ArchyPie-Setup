#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="supermodel"
rp_module_desc="Supermodel: Sega Model 3 Emulator"
rp_module_help="ROM Extension: .zip\n\nCopy Model 3 ROMs To: ${romdir}/model3"
rp_module_licence="GPL3 https://raw.githubusercontent.com/trzy/Supermodel/master/Docs/LICENSE.txt"
rp_module_repo="git https://github.com/trzy/Supermodel master"
rp_module_section="exp"
rp_module_flags="!all x86"

function depends_supermodel() {
    depends_supermodel-sinden
}

function sources_supermodel() {
    gitPullOrClone

    # Set Default Config Path(s)
    applyPatch "${md_data}/01_set_default_config_path.patch"
}

function build_supermodel() {
    make -f Makefiles/Makefile.UNIX clean
    make -f Makefiles/Makefile.UNIX NET_BOARD=1 VERBOSE=1 ARCH="" OPT="${__default_cflags}"

    md_ret_require="${md_build}/bin/${md_id}"
}

function install_supermodel() {
    install_supermodel-sinden
}

function configure_supermodel() {
    configure_supermodel-sinden
}
