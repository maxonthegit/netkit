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


if [ "$(echo /hostlab/shared/*)" != "/hostlab/shared/*" ]; then
   echo "Copying shared files from /hostlab/shared..."
   # Use tar instead of plain cp in order to be able to easily
   # exclude files from the copy. In addition,
   # tar all the files inside the directory instead of just the
   # directory itself, in order to properly cope with virtual
   # machine directories that are symbolic links.
   tar --absolute-names --exclude=CVS --exclude=.svn -c /hostlab/shared/ | \
   tar --absolute-names --no-same-owner --keep-directory-symlink --strip-components=2 -C / -xv | \
   # Now mirror user's permissions to the group and to others, except for directories
   sed -r 's/^\/hostlab\/shared//' | grep -v "/$" | \
   xargs stat --format="%a %n" | { while read PERM FILE; do chmod ${PERM:0:1}${PERM:0:1}${PERM:0:1} $FILE; done; }
fi

if [ "$(echo /hostlab/$HOSTNAME/*)" != "/hostlab/$HOSTNAME/*" ]; then
   echo "Copying $HOSTNAME specific files from /hostlab/$HOSTNAME/..."
   tar --absolute-names --exclude=CVS --exclude=.svn -c /hostlab/$HOSTNAME/ | \
   tar --absolute-names --no-same-owner --keep-directory-symlink --strip-components=2 -C / -xv | \
   sed -r 's/^\/hostlab\/[^/]+//' | grep -v "/$" | \
   xargs stat --format="%a %n" | { while read PERM FILE; do chmod ${PERM:0:1}${PERM:0:1}${PERM:0:1} $FILE; done; }
fi

