#!/usr/bin/bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

if [ "$(id -u)" -ne 0 ]; then
  sudo -E "$0"
  exit $?
fi

scriptdir="$(dirname "$0")"
scriptdir="$(cd "${scriptdir}" && pwd)"

"${scriptdir}/archypie_packages.sh" setup gui
