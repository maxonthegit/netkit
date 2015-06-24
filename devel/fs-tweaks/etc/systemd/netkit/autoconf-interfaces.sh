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
for KERNEL_PARAMETER in "$@"; do
   echo $KERNEL_PARAMETER
done | awk -F= '
   BEGIN {
      ipv4re = "([0-9]+\\.){3}[0-9]+(/[0-9]{1,2})?"

      # The following procedure builds a regular expression to match IPv6 addresses
      # Basic building block: a pair of bytes in hexadecimal format
      bytepair = "[0-9a-fA-F][0-9a-fA-F]?[0-9a-fA-F]?[0-9a-fA-F]?"
      # Beginning of the regular expression
      ipv6re = "("
      # Base case: 8 pairs of bytes separated by ":"
      ipv6re = ipv6re "(" bytepair ":"; for (i=1; i<=6; i++) {ipv6re = ipv6re bytepair ":"}; ipv6re = ipv6re bytepair ")|"
      # Special case: the loopback address "::"
      ipv6re = ipv6re "(::)"
      # Any other case: a sequence of at most i-1 bytes (and at least 1 if i>1) followed
      # by "::" followed by a sequence of at most 8-i bytes (and at least 1 if i<8)
      for (i=1; i<=8; i++) {
         ipv6re = ipv6re "|("
         if (i>1) {ipv6re = ipv6re bytepair}
         for (j=1; j<=6; j++) {
            if ((i==1 && j==1) || j==i-1) {ipv6re = ipv6re "::" bytepair}
            else {ipv6re = ipv6re "(:" bytepair ")?"}
         }
         if (i==1) {ipv6re = ipv6re "(:"bytepair")?"}
         if (i==8) {ipv6re = ipv6re "::"}
         ipv6re = ipv6re ")"
      }
      # End of the regular expression
      ipv6re = ipv6re ")"
   }

   ($1=="netkit.ipaddr") {
      split ($2, a, /,/)
      for (ipspec in a) {
         EXIT_STATUS = 0
         if (a[ipspec] ~ "^eth[0-9]+:" ipv4re "(/[0-9]{1,2})?$" ||
            a[ipspec] ~ "^eth[0-9]+:" ipv6re "(/[0-9]{1,2})?$") {
            interface = substr(a[ipspec], 1, match (a[ipspec], /:/) - 1)
            address = substr(a[ipspec], match (a[ipspec], /:/) + 1)
            system ("/sbin/ip link set " interface " up")
            if (address ~ /:/) { EXIT_STATUS = system ("/sbin/ip -6 addr add " address " dev " interface) }
            else { EXIT_STATUS = system ("/sbin/ip addr add " address " dev " interface) }
            if (EXIT_STATUS > 0) {print "Error while assigning address " address " to interface " interface >"/dev/stderr"; exit 1}
         }
         else {print "Invalid automatically assigned IP addresses in kernel command line: " a[ipspec] >"/dev/stderr"; exit 1}
      }
   }

   ($1=="netkit.defroute") {
      EXIT_STATUS = 0
      if ($2 ~ "^" ipv4re "$" || $2 ~ "^" ipv6re "$") {
         if ($2 ~ /:/) { EXIT_STATUS = system ("/sbin/ip -6 route add default via " $2) }
         else { EXIT_STATUS = system ("/sbin/ip route add default via " $2) }
         if (EXIT_STATUS > 0) {print "Error while setting up default route via " $2 >"/dev/stderr"; exit 1}
      }
      else {print "Invalid default route specification in kernel command line: " $2 >"/dev/stderr"; exit 1}
   }

   ($1=="netkit.ns") {
      EXIT_STATUS = 0
      if ($2 ~ "^" ipv4re "$" || $2 ~ "^" ipv6re "$") {
         EXIT_STATUS = system("/bin/sed -i \"1inameserver " $2 "\" /etc/resolv.conf")
         if (EXIT_STATUS > 0) {print "Error while configuring name server " $2 >"/dev/stderr"; exit 1}
      }
      else {print "Invalid name server specification in kernel command line: " $2 >"/dev/stderr"; exit 1}
   }'


