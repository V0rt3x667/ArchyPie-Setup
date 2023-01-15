#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

ROM="$1"
MODEL="$2"

rootdir="/opt/archypie"
datadir="${HOME}/ArchyPie"
romdir="${datadir}/roms"
biosdir="${datadir}/BIOS"
arpdir="${datadir}/configs/fs-uae"

source "${rootdir}/lib/archivefuncs.sh"

function launch_amiga() {
    case "${MODEL}" in
        CD32)
            "${rootdir}/emulators/fs-uae/bin/fs-uae" \
            --base_dir="${arpdir}" \
            --fullscreen \
            --amiga_model="${MODEL}" \
            --cdrom_drive_0="${ROM}" \
            --cdroms_dir="${romdir}/cd32" \
            --save_states_dir="${romdir}/cd32" \
            --kickstarts_dir="${biosdir}/amiga"
            ;;
        CDTV)
            "${rootdir}/emulators/fs-uae/bin/fs-uae" \
            --base_dir="${arpdir}" \
            --fullscreen \
            --amiga_model="${MODEL}" \
            --cdrom_drive_0="${ROM}" \
            --cdroms_dir="${romdir}/cdtv" \
            --save_states_dir="${romdir}/cdtv" \
            --kickstarts_dir="${biosdir}/amiga"
            ;;
        WHDLOAD)
            "${rootdir}/emulators/fs-uae/bin/fs-uae-launcher" \
            --base-dir="${arpdir}" \
            --fullscreen \
            --no-gui \
            --floppies_dir="${biosdir}/amiga/workbench" \
            --kickstarts_dir="${biosdir}/amiga" \
            --no-auto-detect-game \
            "${ROM}"
            ;;
        A500|A500+|A600|A1200)
            "${rootdir}/emulators/fs-uae/bin/fs-uae" \
            --base_dir="${arpdir}" \
            --fullscreen \
            --amiga_model="${MODEL}" \
            --floppy_drive_0="${ROM}" \
            "${floppy_images[@]}" \
            --floppies_dir="${romdir}/amiga" \
            --save_states_dir="${romdir}/amiga" \
            --kickstarts_dir="${biosdir}/amiga"
            ;;
    esac
}

function check_arch_files() {
    case "${MODEL}" in
        CD32|CDTV|WHDLOAD)
            launch_amiga
            ;;
        A500|A500+|A600|A1200)
            archiveExtract "${ROM}" ".adf .adz .dms .ipf"
            # Check for Successful Extraction
            if [[ $? == 0 ]]; then
                ROM="${arch_files[0]}"
                romdir="${arch_dir}"
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
