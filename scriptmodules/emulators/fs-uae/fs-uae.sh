#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

ROM="$1"
MODEL="$2"

rootdir="/opt/archypie"
datadir="$HOME/ArchyPie"
romdir="$datadir/roms/amiga"
savedir="$romdir"

source "$rootdir/lib/archivefuncs.sh"

function launch_amiga() {
    case "$MODEL" in
        CD32)
            "$rootdir/emulators/fs-uae/bin/fs-uae" \
            --amiga_model="$MODEL" \
            --cdrom_drive_0="$ROM" \
            --cdroms_dir="$datadir/roms/cd32" \
            --save_states_dir="$datadir/roms/cd32"
            ;;
        CDTV)
            "$rootdir/emulators/fs-uae/bin/fs-uae" \
            --amiga_model="$MODEL" \
            --cdrom_drive_0="$ROM" \
            --cdroms_dir="$datadir/roms/cdtv" \
            --save_states_dir="$datadir/roms/cdtv"
            ;;
        A500|A500P|A600|A1200)
            "$rootdir/emulators/fs-uae/bin/fs-uae" \
            --amiga_model="$MODEL" \
            --floppy_drive_0="$ROM" \
            "${floppy_images[@]}" \
            --floppies_dir="$romdir" \
            --save_states_dir="$savedir"
            ;;
    esac
}

function check_arch_files() {
    case "$MODEL" in
        CD32|CDTV)
            launch_amiga
            ;;
        A500|A500P|A600|A1200)
            archiveExtract "$ROM" ".adf .adz .dms .ipf"
            # Check for Successful Extraction
            if [[ $? == 0 ]]; then
                ROM="${arch_files[0]}"
                romdir="$arch_dir"
                floppy_images=()
                for i in "${!arch_files[@]}"; do
                    floppy_images+=("--floppy_image_$i=${arch_files[$i]}")
                done
            fi
            launch_amiga
            ;;
    esac
}

check_arch_files
archiveCleanup
