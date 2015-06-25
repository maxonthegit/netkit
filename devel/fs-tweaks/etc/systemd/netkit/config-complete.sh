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
IS_COW=$(for KERNEL_PARAMETER in "$@"; do
   echo $KERNEL_PARAMETER
done | awk -F= '
   ($1=="ubd0" && $2 ~ /,/) {
      print 1
   }'
)

# Note: using `[ "$IS_COW" == "1" ] && ...' here is not advised, because
# the exit status of the script could coincide with the one of the test,
# causing systemd to detect service startup as failed when IS_COW is
# different from 1.
if [ "$IS_COW" == "1" ]; then
   touch /etc/vhostconfigured
fi

# Notify VM startup completion if this is a lab
if mountpoint -q /hostlab; then
   touch /hostlab/${HOSTNAME}.ready
fi

