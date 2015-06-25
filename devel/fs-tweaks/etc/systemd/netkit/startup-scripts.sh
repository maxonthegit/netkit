#!/bin/bash

#     This script is part of Netkit, a network emulation environment
#     based on the integration of several existing pieces of software.
#     For more information: http://www.netkit.org/
#
#     Copyright (C) 2002-2009, 2015
#         Maurizio Patrignani
#         Stefano Pettini
#         Maurizio Pizzonia
#         Fabio Ricci
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

# Split kernel command line arguments using a standard `for' cycle, then
# use awk for faster extraction of the argument of interest.
EXEC=$(for KERNEL_PARAMETER in "$@"; do
   echo $KERNEL_PARAMETER
done | awk -F= '($1=="exec") {print $2}')

BOLD=$'\e[1;34m'
NORMAL=$'\e[0m'

if [ -f /hostlab/shared.startup ]; then
   echo -e "${BOLD}===== Running shared startup script =====${NORMAL}"
   /bin/sh -c 'source /hostlab/shared.startup'
   echo "${BOLD}^^^^^ End of shared startup script  ^^^^^${NORMAL}"
fi

if [ -f /hostlab/$HOSTNAME.startup ]; then
   echo "${BOLD}===== Running $HOSTNAME-specific startup script =====${NORMAL}"
   /bin/sh -c 'source /hostlab/$HOSTNAME.startup'
   echo "${BOLD}^^^^^ End of $HOSTNAME-specific startup script  ^^^^^${NORMAL}"
fi

if [ -n "$EXEC" ]; then
   echo "${BOLD}=====    Running user-specified command    ====="
   echo ${EXEC}${NORMAL}
   ${EXEC}
   echo "${BOLD}^^^^^ End of user-specified command output ^^^^^${NORMAL}"
fi

