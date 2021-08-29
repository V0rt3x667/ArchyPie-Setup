#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="openbor"
rp_module_desc="OpenBOR - Beat 'Em Up Game Engine"
rp_module_help="OpenBOR games need to be extracted to function properly. Place your pak files in $romdir/ports/openbor and then run $rootdir/ports/openbor/extract.sh. When the script is done, your original pak files will be found in $romdir/ports/openbor/originals and can be deleted."
rp_module_licence="BSD https://raw.githubusercontent.com/DCurrent/openbor/master/LICENSE"
rp_module_repo="git https://github.com/DCurrent/openbor.git master"
rp_module_section="exp"
rp_module_flags="sdl2 !mali"

function depends_openbor() {
    local depends=(
        'libogg'
        'libpng'
        'libvorbis'
        'libvpx'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_openbor() {
    gitPullOrClone
    # Fix Locale Warning
    sed 's|en_US.UTF-8|C|g' -i "$md_build/engine/version.sh"
    # Disable Abort On Warnings & Errors
    sed 's|-Werror||g' -i "$md_build/engine/Makefile"
}

function build_openbor() {
    local params=(SDKPATH=/usr LNXDEV=/usr/bin BUILD_LINUX=1 GCC_TARGET="$CARCH")
    ! isPlatform "x11" && params+=(NO_GL=1)

    cd "$md_build/engine"
    ./version.sh
    make clean
    make "${params[@]}"

    cd "$md_build/tools/borpak/source"
    chmod a+x ./build.sh
    ./build.sh lin
    md_ret_require="$md_build/engine/OpenBOR"
}

function install_openbor() {
    md_ret_files=(
       'engine/OpenBOR'
       'tools/borpak/scripts/packer'
       'tools/borpak/scripts/paxplode'
       'tools/borpak/source/borpak'
    )
}

function configure_openbor() {
    addPort "$md_id" "openbor" "OpenBOR - Beats of Rage Engine" "$md_inst/openbor.sh"

    mkRomDir "ports/$md_id"
    isPlatform "dispmanx" && setBackend "$md_id" "dispmanx"

    cat >"$md_inst/openbor.sh" << _EOF_
#!/bin/bash
pushd "$md_inst"
./OpenBOR "\$@"
popd
_EOF_
    chmod +x "$md_inst/openbor.sh"

    cat >"$md_inst/extract.sh" <<_EOF_
#!/bin/bash
PORTDIR="$md_inst"
BORROMDIR="$romdir/ports/$md_id"
mkdir \$BORROMDIR/original/
mkdir \$BORROMDIR/original/borpak/
mv \$BORROMDIR/*.pak \$BORROMDIR/original/
cp \$PORTDIR/paxplode.sh \$BORROMDIR/original/
cp \$PORTDIR/borpak \$BORROMDIR/original/borpak/
cd \$BORROMDIR/original/
for i in *.pak
do
  CURRENTFILE=\`basename "\$i" .pak\`
  ./paxplode "\$i"
  mkdir "\$CURRENTFILE"
  mv data/ "\$CURRENTFILE"/
  mv "\$CURRENTFILE"/ ../
done

echo "Your games are extracted and ready to be played. Your originals are stored safely in $BORROMDIR/original/ but they won't be needed anymore. Everything within it can be deleted."
_EOF_
    chmod +x "$md_inst/extract.sh"

    local dir
    for dir in ScreenShots Logs Saves; do
        mkUserDir "$md_conf_root/$md_id/$dir"
        ln -snf "$md_conf_root/$md_id/$dir" "$md_inst/$dir"
    done

    ln -snf "$romdir/ports/$md_id" "$md_inst/Paks"
}
