#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="hypseus-singe"
rp_module_desc="Hypseus-Singe - Super Multiple Arcade Laserdisc Emulator"
rp_module_help="ROM Extension: .daphne\n\nCopy Your Laserdisc ROMs to $romdir/daphne"
rp_module_licence="GPL3 https://raw.githubusercontent.com/DirtBagXon/hypseus-singe/master/LICENSE"
rp_module_repo="git https://github.com/DirtBagXon/hypseus-singe.git :_get_branch_hypseus-singe"
rp_module_section="main"
rp_module_flags=""

function _get_branch_hypseus-singe() {
    download https://api.github.com/repos/DirtBagXon/hypseus-singe/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_hypseus-singe() {
    local depends=(
        'libvorbis'
        'sdl2'
        'sdl2_image'
        'sdl2_ttf'
        'zlib'
        'cmake'
    )
    getDepends "${depends[@]}"
}

function sources_hypseus-singe() {
    gitPullOrClone
}

function build_hypseus-singe() {
    mkdir build

    cd build
    cmake ../src \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON
    make clean
    make

    md_ret_require=('$md_build/build/hypseus')
}

function install_hypseus-singe() {
    cd "$md_build/build"
    make install
}

function configure_hypseus-singe() {
    local dirs
    dirs=(
        'pics'
        'ram'
        'roms'
        'sound'
        'singe'
        'vldp'
        'vldp_dl'
    )
    for dir in "${dirs[@]}"; do
        mkRomDir "daphne/$dir"
    done

    mkUserDir "$md_conf_root/daphne"
    moveConfigDir "$home/.hypseus" "$md_conf_root/daphne"

    if [[ "$md_mode" == "install" ]] && [[ ! -f "$md_conf_root/daphne/hypinput.ini && ! -f $md_conf_root/daphne/flightkey.ini" ]]; then
        cp -v "$md_inst/doc/"*.ini "$md_conf_root/daphne"
        cp -r "$md_inst/fonts" "$md_conf_root/daphne"
        chown -R "$user:$user" "$md_conf_root/daphne"
    fi

    addEmulator 1 "$md_id" "daphne" "$md_inst/daphne %ROM%"
    addSystem "daphne"

    [[ "$md_mode" == "remove" ]] && return

    cat >"$md_inst/daphne.sh" <<_EOF_
#!/usr/bin/bash

HYPSEUS_SHARE="$romdir/daphne"
HYPSEUS_BIN="md_inst/hypseus"

    case "$1" in
        ace)
            VLDP_DIR="vldp_dl"
            FASTBOOT="-fastboot"
            BANKS="-bank 1 00000001 -bank 0 00000010"
            ;;
        astron)
            VLDP_DIR="vldp"
            KEYINPUT="-keymapfile flightkey.ini"
            ;;
        badlands)
            VLDP_DIR="vldp"
            BANKS="-bank 1 10000001 -bank 0 00000000"
            ;;
        bega)
            VLDP_DIR="vldp"
            ;;
        blazer)
            VLDP_DIR="vldp"
            KEYINPUT="-keymapfile flightkey.ini"
            ;;
        cliff)
            VLDP_DIR="vldp"
            FASTBOOT="-fastboot"
            BANKS="-bank 1 00000000 -bank 0 00000000 -cheat"
            ;;
        cobra)
            VLDP_DIR="vldp"
            KEYINPUT="-keymapfile flightkey.ini"
            ;;
        cobraab)
            VLDP_DIR="vldp"
            KEYINPUT="-keymapfile flightkey.ini"
            ;;
        dle21)
            VLDP_DIR="vldp_dl"
            BANKS="-bank 1 00110111 -bank 0 11011000"
            ;;
        esh)
            # Run a Fixed ROM So Disable CRC
            VLDP_DIR="vldp"
            FASTBOOT="-nocrc"
            ;;
        galaxy)
            VLDP_DIR="vldp"
            KEYINPUT="-keymapfile flightkey.ini"
            ;;
        gpworld)
            VLDP_DIR="vldp"
            ;;
        interstellar)
            VLDP_DIR="vldp"
            KEYINPUT="-keymapfile flightkey.ini"
            ;;
        mach3)
            VLDP_DIR="vldp"
            BANKS="-bank 0 01000001"
            KEYINPUT="-keymapfile flightkey.ini"
            ;;
        lair)
            VLDP_DIR="vldp_dl"
            FASTBOOT="-fastboot"
            BANKS="-bank 1 00110111 -bank 0 10011000"
            ;;
        lair2)
            VLDP_DIR="vldp_dl"
            ;;
        roadblaster)
            VLDP_DIR="vldp"
            ;;
        sae)
            VLDP_DIR="vldp_dl"
            BANKS="-bank 1 01100111 -bank 0 10011000"
            ;;
        sdq)
            VLDP_DIR="vldp"
            BANKS="-bank 1 00000000 -bank 0 00000000"
            ;;
        tq)
            VLDP_DIR="vldp_dl"
            BANKS=" -bank 0 00010000"
            ;;
        uvt)
            VLDP_DIR="vldp"
            BANKS="-bank 0 01000000"
            KEYINPUT="-keymapfile flightkey.ini"
            ;;
        *)
            echo -e "\nInvalid game selected\n"
            exit 1
    esac

    if [ ! -f $HYPSEUS_SHARE/$VLDP_DIR/$1/$1.txt ]; then
        echo
        echo "Missing Frame File: $HYPSEUS_SHARE/$VLDP_DIR/$1/$1.txt ?" | STDERR
        echo
        exit 1
    fi

    "$HYPSEUS_BIN" $1 vldp \
    "$FASTBOOT" \
    "$KEYINPUT" \
    "$BANKS" \
    -framefile "$HYPSEUS_SHARE/$VLDP_DIR/$1/$1.txt" \
    -homedir "$home/.hypseus" \
    -datadir "$HYPSEUS_SHARE" \
    -fullscreen
    -sound_buffer 2048 \
    -volume_nonvldp 5 \
    -volume_vldp 20
_EOF_
    chmod +x "$md_inst/daphne.sh"
}
