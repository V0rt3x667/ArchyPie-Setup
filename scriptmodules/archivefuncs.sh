#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

## @file archivefuncs.sh
## @brief archypie archivefuncs library
## @copyright GPLv3

readonly arch_dir="/tmp/archypie-archive"

## @fn archiveExtract()
## @param src_file Full path to archive file to extract
## @param disk_exts Space separated list of supported disk extensions (e.g. ".d64 .t64")
## @brief Extracts an archive to a temporary directory
## @details After calling this the variable arch_dir will contain the directory that was used
## for extraction. Also the variable arch_files will contain an array of filenames that are
## considered as game disks according to parameter disk_exts.
function archiveExtract() {
    local src_file="$1"
    local disk_exts="$2"

    # clean temp directory if needed
    archiveCleanup
    mkdir "$arch_dir"

    local ext="${src_file##*.}"

    case "${ext,,}" in
        zip)
            unzip "$src_file" -d "$arch_dir"
            ;;
        *)
            echo "Unsupported archive: $src_file"
            return 1
            ;;
    esac

    # build a regex portion from the passed extensions
    local regex="${disk_exts// /\\|}"

    IFS=$'\n' read -d '' -r -a arch_files < <(find "$arch_dir" -iregex ".*.\(${regex}\)$" | sort)

    if [[ ${#arch_files[@]} -eq 0 ]]; then
        return 2
    fi
}

## @fn archiveCleanup()
## @brief Purges archive temp directory from previous calls to archiveExtract
function archiveCleanup() {
    [[ -d "$arch_dir" ]] && rm -rf "$arch_dir"
}
