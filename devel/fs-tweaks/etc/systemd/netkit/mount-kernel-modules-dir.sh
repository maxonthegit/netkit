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

for KERNEL_PARAMETER in "$@"; do
   if [ "$(echo "$KERNEL_PARAMETER" | cut -d = -f 1)" = "modules" ]; then
      MODULES_DIR="$(echo "$KERNEL_PARAMETER" | cut -d = -f 2-)"
   fi
done

if [ -n "$MODULES" ]; then
   # Write access is needed for depmod in order to work properly
   mount none /lib/modules/ -t hostfs -o rw,"$MODULES_DIR/lib/modules"
fi

