#!/bin/bash
is_amiberry=0

emulator="./uae4arm"
[[ "${is_amiberry}" -eq 1 ]] && emulator="./amiberry"

pushd "${0%/*}" >/dev/null
source "../../lib/archivefuncs.sh"

params=()

arg="$1"

if [[ "${arg}" == *.uae ]]; then
    config="${arg}"
else
    rom="${arg}"
fi
shift

images=()

if [[ "${is_amiberry}" -eq 1 ]] && [[ "${rom}" == *.lha || "${rom}" == *.cue || "${rom}" == *.chd ]]; then
    params+=(--autoload "${rom}")
elif [[ -n "${rom}" ]]; then
    # Check For Successful Extraction
    if archiveExtract "${rom}" ".adf .adz .dms .ipf"; then
        for i in {0..3}; do
            [[ -n "${arch_files[$i]}" ]] && images+=(-"$i" "${arch_files[$i]}")
        done
        name="${arch_files[0]}"
    elif [[ -n "${rom}" ]]; then
        name="${rom}"
        # Find The Disk Series
        base="${name##*/}"
        base="${base%Disk*}"
        i=0
        while read -r disk; do
            images+=(-"$i" "${disk}")
            ((i++))
            [[ "$i" -eq 4 ]] && break
        done < <(find "${rom%/*}" -iname "${base}*" | sort)
        [[ "${#images[@]}" -eq 0 ]] && images=(-0 "${rom}")
    fi

    rom_path="${rom%/*}"
    rom_name="${rom##*/}"
    rom_bn="${rom_name%.*}"

    # Check For .UAE Files With The Same Base Name As The Adf/Zip In The Rom Directory And Conf
    if [[ -f "${rom_path}/${rom_bn}.uae" ]]; then
        config="${rom_path}/${rom_bn}.uae"
    elif [[ -f "conf/${rom_bn}.uae" ]]; then
        config="conf/${rom_bn}.uae"
    # If No Config Or Model Parameters Are Included In The Arguments Choose A Config/Model Automatically
    elif [[ "$*" != *-config* && "$*" != *--model* ]]; then
        # If Amiberry Choose A Model For Amiberry Based On The ROM Filename
        if [[ "${is_amiberry}" -eq 1 ]]; then
            model="A500"
            case "${name}" in
                *ECS*)
                    model="A500P"
                    ;;
                *AGA*)
                    model="A1200"
                    ;;
                *CD32*)
                    model="CD32"
                    ;;
                *CDTV*)
                    model="CDTV"
                    ;;
            esac
            params+=(--model "${model}")
        else
            # For UAE4arm Choose An Amiga Config Based On The ROM Filename
            if [[ "${name}" =~ AGA|CD32 ]]; then
                config="conf/rp-a1200.uae"
            else
                config="conf/rp-a500.uae"
            fi
        fi
    fi
fi

# If There Is A Config Set Then Use It
if [[ -n "${config}" ]]; then
    if [[ "${is_amiberry}" -eq 1 ]]; then
        params+=(--config "${config}")
    else
        params+=(-config="${config}")
    fi
fi

# Add Any Other Provided Arguments
params+=("$@")

# Add Images To Parameters (Needs To Be After Any Config Arguments)
params+=("${images[@]}")

# Start Directly Into Emulation If The First Argument Is Set
[[ -n "${arg}" ]] && params+=(-G)

echo "Launching ..."
echo "${emulator}" "${params[@]}"

"${emulator}" "${params[@]}"
archiveCleanup

popd || exit
