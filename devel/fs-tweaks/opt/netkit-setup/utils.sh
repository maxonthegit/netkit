#!/bin/sh

#     This script is part of Netkit, a network emulation environment based on
#     the integration of several existing pieces of software.
#     For more information: http://www.netkit.org/
#
#     Copyright (C) 2015
#         Massimo Rimondini (rimondin@ing.uniroma3.it)
#     Computer Networks Research Group, Roma Tre University
# 
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, version 3 of the License.
# 
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>.

if type source >/dev/null 2>&1; then
   # We are using bash
   EMPH=$'\033[35;1m'
   NORMAL=$'\033[0m'
else
   # We are using dash
   EMPH='\033[35;1m'
   NORMAL='\033[0m'
fi

becho() {
   echo "${EMPH}$*${NORMAL}"
}

# Exit if any commands fail
set -e

