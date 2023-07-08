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
    if [[ "$(aplay -ql | grep -c bcm2835)" -lt 1 ]]; then
        printMsgs "dialog" "On-board Audio Disabled Or Not Present"
        return
    fi

    # The List Of ALSA Cards Depends On The "snd-bcm2385" Module Parameter "enable_compat_alsa"
    # * enable_compat_alsa: true - Single Soundcard, Output Is Routed Based On The "numid" Control
    # * enable_compat_alsa: false - One Soundcard Per Output Type (HDMI/Headphones)
    # If PulseAudio Is Enabled Then Try To Configure It And Leave ALSA Alone
    if _pa_cmd_audiosettings systemctl -q --user is-enabled pulseaudio.socket; then
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
    printMsgs "dialog" "Audio Settings Reset to Defaults"
}

function _move_old_config_audiosettings() {
    if [[ -f "${home}/.asoundrc" && ! -f "/etc/alsa/conf.d/99-archypie.conf" ]]; then
        if dialog --yesno "The ALSA audio configuration for ArchyPie has moved from ${home}/.asoundrc to /etc/alsa/conf.d/99-archypie.conf\n\nYou have a configuration in ${home}/.asoundrc - do you want to move it to the new location? If ${home}/.asoundrc contains your own changes you should choose 'No'." 20 76 2>&1 >/dev/tty; then
            mv "${home}/.asoundrc" "/etc/alsa/conf.d/"
        fi
    fi
}

function _bcm2835_alsa_compat_audiosettings() {
    _move_old_config_audiosettings

    local cmd=(dialog --backtitle "${__backtitle}" --menu "Set Audio Output (ALSA - Compat)" 22 86 16)
    local hdmi="HDMI"

    # The Raspberry Pi 4 Has 2 HDMI Ports
    isPlatform "rpi4" && hdmi="HDMI 1"

    local options=(
        1 "Auto"
        2 "Headphones: 3.5mm Jack"
        3 "${hdmi}"
    )
    # Add 2nd HDMI Port On The Raspberry Pi 4
    isPlatform "rpi4" && options+=(4 "HDMI 2")
    options+=(
        M "Mixer: Adjust Output Volume"
        R "Reset To Default"
    )
    # If PulseAudio Is Installed Add An Option To Enable It
    hasPackage "pulseaudio" && options+=(P "Enable PulseAudio")

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
                _toggle_pulseaudio_audiosettings "on"
                printMsgs "dialog" "PulseAudio Enabled"
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
    done < <(aplay -ql | sed -En 's/^card ([0-9]+).*\[bcm2835 ([^]]*)\].*/\1 \2/p')

    options+=(
        M "Mixer: Adjust Output Volume"
        R "Reset To Default"
    )

    # If PulseAudio Is Installed Add An Option To Enable It
    hasPackage "pulseaudio" && options+=(P "Enable PulseAudio")

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
                _toggle_pulseaudio_audiosettings "on"
                printMsgs "dialog" "PulseAudio Enabled"
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
        # when the 'vc4hdmi' driver is used instead of 'bcm2835_audio' for HDMI,
        # the 'hdmi:vchdmi[-idx]' PCM should be used for converting to the native IEC958 codec
        # adds a volume control since the default configured mixer doesn't work
        # (default configuration is at /usr/share/alsa/cards/vc4-hdmi.conf)
        local card_name
        card_name="$(cat /proc/asound/card${card_index}/id)"
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
  card ${card_index}
}
pcm.softvolume {
    type           softvol
    slave.pcm      "hdmi${card_index}"
    control.name  "HDMI Playback Volume"
    control.card  ${card_index}
}

pcm.softmute {
    type softvol
    slave.pcm "softvolume"
    control.name "HDMI Playback Switch"
    control.card ${card_index}
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
  card ${card_index}
}
ctl.!default {
  type hw
  card ${card_index}
}
EOF
    fi
    local dest="/etc/alsa/conf.d/99-archypie.conf"
    mv "${tmpfile}" "${dest}"
    chmod 644 "${dest}"
}

function _pulseaudio_audiosettings() {
    local cmd=(dialog --backtitle "${__backtitle}" --menu "Set Audio Output (PulseAudio)." 22 86 16)
    local options=()
    local sink_index
    local sink_label

    # Check If PulseAudio Is Running Otherwise 'pacmd' Will Not Work
    if ! _pa_cmd_audiosettings pacmd stat>/dev/null; then
        printMsgs "dialog" "PulseAudio Is Enabled But Not Running\nAudio Settings Cannot Be Set Right Now"
        return
    fi
    while read -r sink_index sink_label; do
        options+=("${sink_index}" "${sink_label}")
    done < <(_pa_cmd_audiosettings pacmd list-sinks | \
            awk -F [:=] '/index/ { idx=$2;
                         do {getline} while($0 !~ "alsa.name");
                         gsub(/"|bcm2835[^a-zA-Z]+/, "", $2);
                         print idx,$2 }'
            )

    options+=(
        M "Mixer: Adjust Output Volume"
        R "Reset To Default"
        P "Disable PulseAudio"
    )
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "${choice}" ]]; then
        case "${choice}" in
            [0-9])
                _pa_cmd_audiosettings pactl set-default-sink "${choice}"
                rm -f "/etc/alsa/conf.d/99-archypie.conf"
                printMsgs "dialog" "Set Audio Output To: ${options[$((choice*2+1))]}"
                ;;
            M)
                alsamixer >/dev/tty </dev/tty
                alsactl store
                ;;
            R)
                rm -fr "${home}/.config/pulse"
                alsactl restore
                alsactl store
                printMsgs "dialog" "Audio Settings Reset To Defaults"
                ;;
            P)
                _toggle_pulseaudio_audiosettings "off"
                printMsgs "dialog" "PulseAudio Disabled"
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

# Run PulseAudio Commands As The Calling User
function _pa_cmd_audiosettings() {
    [[ -n "$*" ]] && sudo -u "${user}" "XDG_RUNTIME_DIR=/run/user/${SUDO_UID}" "${@}" 2>/dev/null
}
