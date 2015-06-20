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


# Avoid spanning too many subprocesses in the for cycle, which is
# detrimental for performance. The `for' shell primitive is still used here
# to correctly split quoted parameters.

for KERNEL_PARAMETER in "$@"; do
   echo $KERNEL_PARAMETER
done | awk -F= '
   ($1=="hosthome") {
      system("mkdir -p /hosthome")
      system("mount none /hosthome -t hostfs -o rw,\"" substr($0,10) "\"")
   }
   ($1=="hostlab") {
      system("mkdir -p /hostlab")
      system("mount none /hostlab -t hostfs -o rw,\"" substr($0,9) "\"")
   }'

