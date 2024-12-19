#!/bin/bash

################################################################################
# This file is part of the ArchyPie Project                                    #
#                                                                              #
# Please see the LICENSE file at the top-level directory of this distribution. #
################################################################################

scriptdir="$(dirname "${0}")"
scriptdir="$(cd "${scriptdir}" && pwd)"

"${scriptdir}/archypie_packages.sh" setup gui
