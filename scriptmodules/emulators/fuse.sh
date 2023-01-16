#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="fuse"
rp_module_desc="Fuse: ZX Spectrum Emulator"
rp_module_help="ROM Extensions: .dsk .gz .img .mgt .scl .sh .sna .szx .tap .trd .tzx .udi .z80 .zip\n\nCopy ZX Spectrum Games To: ${romdir}/zxspectrum"
rp_module_licence="GPL2 https://sourceforge.net/p/fuse-emulator/fuse/ci/master/tree/COPYING"
rp_module_repo="git https://git.code.sf.net/p/fuse-emulator/fuse master"
rp_module_section="opt"
rp_module_flags=""

function depends_fuse() {
    local depends=(
        'audiofile'
        'bison'
        'flex'
        'lbzip2'
        'libpng'
        'sdl12-compat'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_fuse() {
    gitPullOrClone

    _sources_libspectrum
}

function _sources_libspectrum() {
    gitPullOrClone "${md_build}/libspectrum" "https://git.code.sf.net/p/fuse-emulator/libspectrum"

    # Set Default Config Path(s)
    applyPatch "${md_data}/01_set_default_config_path.patch"

    if ! isPlatform "x11"; then
        applyPatch "${md_data}/02_disable_cursor.patch"
    fi
}

function _build_libspectrum() {
    cd "${md_build}/libspectrum" || exit
    ./autogen.sh
    ./configure --disable-shared
    make clean
    make
    md_ret_require="${md_build}/libspectrum.so"
}

function build_fuse() {
    _build_libspectrum

    cd "${md_build}" || exit
    ./autogen.sh
    ./configure LIBSPECTRUM_CFLAGS="-I${md_build}/libspectrum" LIBSPECTRUM_LIBS="-L${md_build}/libspectrum/.libs -lspectrum" \
        --prefix="${md_inst}" \
        --without-libao \
        --without-gpm \
        --without-gtk \
        --without-libxml2 \
        --with-sdl
    make clean
    make
    md_ret_require="${md_build}/${md_id}"
}

function install_fuse() {
    make install
    md_ret_require="${md_inst}/bin/${md_id}"
}

function configure_fuse() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/zxspectrum/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "zxspectrum"

        local script="${romdir}/zxspectrum/+Start Fuse.sh"
    cat > "${script}" << _EOF_
#!/bin/bash
${md_inst}/bin/${md_id} --machine 128 --full-screen
_EOF_
    chown "${user}:${user}" "${script}"
    chmod +x "${script}"
    fi

    addEmulator 0 "${md_id}-48k" "zxspectrum" "${md_inst}/bin/fuse --machine 48 --full-screen %ROM%"
    addEmulator 0 "${md_id}-128k" "zxspectrum" "${md_inst}/bin/fuse --machine 128 --full-screen %ROM%"

    addSystem "zxspectrum"
}
