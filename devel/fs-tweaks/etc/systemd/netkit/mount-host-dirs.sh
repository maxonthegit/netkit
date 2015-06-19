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
   PARAM_NAME=$(echo "$KERNEL_PARAMETER" | cut -d = -f 1)
   case "$PARAM_NAME" in
      hosthome)
         HOSTHOME="$(echo "$KERNEL_PARAMETER" | cut -d = -f 2-)"
         mkdir -p /hosthome
         mount none /hosthome -t hostfs -o rw,"$HOSTHOME"
         ;;
      hostlab)
         HOSTLAB="$(echo "$KERNEL_PARAMETER" | cut -d = -f 2-)"
         mkdir -p /hostlab
         mount none /hostlab -t hostfs -o rw,"$HOSTLAB"
         ;;
   esac
done

