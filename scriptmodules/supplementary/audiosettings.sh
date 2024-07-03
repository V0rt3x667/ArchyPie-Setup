#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="audiosettings"
rp_module_desc="Raspberry Pi Audio Configuration"
rp_module_section="config"
rp_module_flags="!all rpi"

function depends_audiosettings() {
    local depends=('alsa-utils')

    getDepends "${depends[@]}"
}

function gui_audiosettings() {
    # Check If The Internal Audio Is Enabled
    if [[ "$(aplay -ql | grep -e bcm2835 -e vc4hdmi | wc -l)" -le 1 ]]; then
        printMsgs "dialog" "On-board Audio Disabled Or Not Present"
        return
    fi

    # The List Of ALSA Cards Depends On The "snd-bcm2385" Module Parameter "enable_compat_alsa"
    # * enable_compat_alsa: true - Single Soundcard, Output Is Routed Based On The "numid" Control
    # * enable_compat_alsa: false - One Soundcard Per Output Type (HDMI/Headphones)
    # If PulseAudio Is Enabled Then Try To Configure It And Leave ALSA Alone
    if _pa_cmd_audiosettings systemctl -q --user is-enabled {pulseaudio,pipewire-pulse}.service; then
        _pulseaudio_audiosettings
    elif aplay -l | grep -q "bcm2835 ALSA"; then
        _bcm2835_alsa_compat_audiosettings
    else
        _bcm2835_alsa_internal_audiosettings
    fi
}

function _reset_alsa_audiosettings() {
    alsactl restore
    alsactl store
    rm -f "${home}/.asoundrc" "/etc/alsa/conf.d/99-archypie.conf"
    printMsgs "dialog" "Audio Settings Reset To Defaults"
}

function _move_old_config_audiosettings() {
    if [[ -f "${home}/.asoundrc" && ! -f "/etc/alsa/conf.d/99-archypie.conf" ]]; then
        if dialog --yesno "The ALSA audio configuration for ArchyPie has moved from ${home}/.asoundrc to /etc/alsa/conf.d/99-archypie.conf\n\nYou have a configuration in ${home}/.asoundrc - do you want to move it to the new location? If ${home}/.asoundrc contains your own changes you should choose 'No'." 20 76 2>&1 >/dev/tty; then
            mkdir -p /etc/alsa/conf.d
            mv "${home}/.asoundrc" "/etc/alsa/conf.d/"
        fi
    fi
}

function _bcm2835_alsa_compat_audiosettings() {
    _move_old_config_audiosettings

    local cmd=(dialog --backtitle "${__backtitle}" --menu "Set Audio Output (ALSA - Compat)" 22 86 16)
    local hdmi="HDMI"

    # The Raspberry Pi 4/5 Has 2 HDMI Ports
    (isPlatform "rpi4" || isPlatform "rpi5") && hdmi="HDMI 1"

    local options=(
        1 "Auto"
        2 "Headphones: 3.5mm Jack"
        3 "${hdmi}"
    )
    # Add 2nd HDMI Port On The Raspberry Pi 4/5
    (isPlatform "rpi4" || isPlatform "rpi5") && options+=(4 "HDMI 2")
    options+=(
        M "Mixer: Adjust Output Volume"
        R "Reset To Default"
    )
    # If PulseAudio (PipeWire) Is Installed Add An Option To Enable It
    local sound_server="PulseAudio"
    if hasPackage "wireplumber"; then
        options+=(P "Enable PipeWire")
    else
    hasPackage "pulseaudio" && options+=(P "Enable PulseAudio")
    fi
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "${choice}" ]]; then
        case "${choice}" in
            1)
                amixer cset numid=3 0
                alsactl store
                printMsgs "dialog" "Set Audio Output To Auto"
                ;;
            2)
                amixer cset numid=3 1
                alsactl store
                printMsgs "dialog" "Set Audio Output To Headphones: 3.5mm Jack"
                ;;
            3)
                amixer cset numid=3 2
                alsactl store
                printMsgs "dialog" "Set Audio Output To ${hdmi}"
                ;;
            4)
                amixer cset numid=3 3
                alsactl store
                printMsgs "dialog" "Set Audio Output To HDMI 2"
                ;;
            M)
                alsamixer >/dev/tty </dev/tty
                alsactl store
                ;;
            R)
                _reset_alsa_audiosettings
                ;;
            P)
                _toggle_${sound_server,,} audiosettings "on"
                printMsgs "dialog" "${sound_server} Enabled"
                ;;
        esac
    fi
}

function _bcm2835_alsa_internal_audiosettings() {
    _move_old_config_audiosettings

    local cmd=(dialog --backtitle "${__backtitle}" --menu "Set Audio Output (ALSA)" 22 86 16)
    local options=()
    local card_index
    local card_label

    # Get The List Of Raspberry Pi Internal Cards
    while read -r card_no card_label; do
        options+=("${card_no}" "${card_label}")
    done < <(aplay -ql | sed -En -e '/^card/ {s/^card ([0-9]+).*\[(bcm2835 |vc4-)([^]]*)\].*/\1 \3/; s/hdmi[- ]?/HDMI /i; p}')

    options+=(
        M "Mixer: Adjust Output Volume"
        R "Reset To Default"
    )

    # If PulseAudio (PipeWire) Is Installed Add An Option To Enable It
    local sound_server="PulseAudio"
    if hasPackage "wireplumber"; then
        options+=(P "Enable PipeWire")
        sound_server="PipeWire"
    else
    hasPackage "pulseaudio" && options+=(P "Enable PulseAudio")
    fi

    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "${choice}" ]]; then
        case "${choice}" in
            [0-9])
                _asoundrc_save_audiosettings "${choice}" "${options[$((choice*2+1))]}"
                printMsgs "dialog" "Set Audio Output To: ${options[$((choice*2+1))]}"
                ;;
            M)
                alsamixer >/dev/tty </dev/tty
                alsactl store
                ;;
            R)
                _reset_alsa_audiosettings
                ;;
            P)
                _toggle_${sound_server,,}_audiosettings "on"
                printMsgs "dialog" "${sound_server} Enabled"
                ;;
        esac
    fi
}

# Configure The Default ALSA Soundcard Based On Chosen Card
function _asoundrc_save_audiosettings() {
    [[ -z "${1}" ]] && return

    local card_index=${1}
    local card_type=${2}
    local tmpfile
    tmpfile="$(mktemp)"

    if isPlatform "kms" && [[ ${card_type} == "HDMI"* ]]; then
        # When The 'vc4hdmi' Driver Is Used Instead Of 'bcm2835_audio' For HDMI,
        # The 'hdmi:vchdmi[-idx]' PCM Should Be Used For Converting To The Native IEC958 Codec
        # Adds A Volume Control Since The Default Configured Mixer Doesn't Work
        # (Default Configuration Is At /usr/share/alsa/cards/vc4-hdmi.conf)
        local card_name
        card_name="$(cat /proc/asound/card"${card_index}"/id)"
        cat << EOF > "${tmpfile}"
pcm.hdmi${card_index} {
  type asym
  playback.pcm {
    type plug
    slave.pcm "hdmi:${card_name}"
  }
}
ctl.!default {
  type hw
  card "${card_index}"
}
pcm.softvolume {
    type softvol
    slave.pcm "hdmi${card_index}"
    control.name "HDMI Playback Volume"
    control.card "${card_index}"
}

pcm.softmute {
    type softvol
    slave.pcm "softvolume"
    control.name "HDMI Playback Switch"
    control.card "${card_index}"
    resolution 2
}

pcm.!default {
    type plug
    slave.pcm "softmute"
}
EOF
    else
    cat << EOF > "${tmpfile}"
pcm.!default {
  type asym
  playback.pcm {
    type plug
    slave.pcm "output"
  }
}
pcm.output {
  type hw
  card "${card_index}"
}
ctl.!default {
  type hw
  card "${card_index}"
}
EOF
    fi
    local dest="/etc/alsa/conf.d/99-archypie.conf"
    mkdir -p /etc/alsa/conf.d
    mv "${tmpfile}" "${dest}"
    chmod 644 "${dest}"
}

function _pulseaudio_audiosettings() {
    local options=()
    local sink_index
    local sink_label
    local sinks=()
    local sound_server="PulseAudio"

    # Check If PulseAudio Is Running Otherwise 'pacmd' Will Not Work
    if ! _pa_cmd_audiosettings pactl info >/dev/null; then
        printMsgs "dialog" "PulseAudio Is Present But Not Running\nAudio Settings Cannot Be Set Right Now"
        return
    fi
    while read -r sink_index sink_label sink_id; do
        options+=("${sink_index}" "${sink_label}")
        sinks[${sink_index}]=${sink_id}
    done < <(_pa_cmd_audiosettings pactl list sinks | \
            awk -F [:=#] 'BEGIN {idx=0} /Sink/ {
                             ctl_index=$2
                             do {getline} while($0 !~ /card.name/ && $0 !~ /Formats/);
                             if ( $2 != "" ) {
                                gsub(/"|bcm2835[^a-zA-Z]+/, "", $2); # strip bcm2835 suffix on analog output
                                gsub(/vc4[-]?/ , "", $2); # strip the vc4 suffix on HDMI output(s)
                                if ( $2 ~ /hdmi/ ) $2=toupper($2)
                                print idx,$2,ctl_index
                                idx++
                             }
                         }'
            )
    _pa_cmd_audiosettings pactl info | grep -i pipewire >/dev/null && sound_server="PipeWire"
    local cmd=(dialog --backtitle "${__backtitle}" --menu "Set Audio Output (${sound_server})" 22 86 16)
    options+=(
        M "Mixer: Adjust Output Volume"
        R "Reset To Default"
        P "Disable ${sound_server}"
    )
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "${choice}" ]]; then
        case "${choice}" in
            [0-9]*)
                _pa_cmd_audiosettings pactl set-default-sink "${sinks[$choice]}"
                rm -f "/etc/alsa/conf.d/99-archypie.conf"

                printMsgs "dialog" "Set Audio Output To: ${options[$((choice*2+1))]}"
                ;;
            M)
                _pa_cmd_audiosettings alsamixer >/dev/tty </dev/tty
                alsactl store
                ;;
            R)
                rm -fr "${home}/.config/pulse"
                alsactl restore
                alsactl store
                printMsgs "dialog" "Audio Settings Reset To Defaults"
                ;;
            P)
                _toggle_${sound_server,,}_audiosettings "off"
                printMsgs "dialog" "${sound_server} Disabled"
                ;;
        esac
    fi
}

function _toggle_pulseaudio_audiosettings() {
    local state=${1}

    if [[ "${state}" == "on" ]]; then
        _pa_cmd_audiosettings systemctl --user unmask pulseaudio.socket
        _pa_cmd_audiosettings systemctl --user start  pulseaudio.service
    fi

    if [[ "${state}" == "off" ]]; then
        _pa_cmd_audiosettings systemctl --user mask pulseaudio.socket
        _pa_cmd_audiosettings systemctl --user stop pulseaudio.service
    fi
}

function _toggle_pipewire_audiosettings() {
    local state=${1}

    if [[ "${state}" == "on" ]]; then
        _pa_cmd_audiosettings systemctl --user unmask pipewire-pulse.socket pipewire.socket
        _pa_cmd_audiosettings systemctl --user start  pipewire.service pipewire-pulse.service wireplumber.service
    fi

    if [[ "${state}" == "off" ]]; then
        _pa_cmd_audiosettings systemctl --user mask pipewire-pulse.socket pipewire.socket
        _pa_cmd_audiosettings systemctl --user stop pipewire.service pipewire-pulse.service wireplumber.service
     fi
}

# Run PulseAudio commands as the calling user
function _pa_cmd_audiosettings() {
    [[ -n "${@}" ]] && sudo -u "${user}" "XDG_RUNTIME_DIR=/run/user/${SUDO_UID}" "${@}" 2>/dev/null
}
