#!/bin/bash

#     This script is part of Netkit, a network emulation environment
#     based on the integration of several existing pieces of software.
#     For more information: http://www.netkit.org/
#
#     Copyright (C) 2002-2009, 2015
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


# This script is used to generate test signatures. It is meant to be run from
# inside virtual machines.

# ANSI style escape sequences
BOLD=$'\e[34;1m'
NORMAL=$'\e[0m'
#HIDE_CURSOR=$'\e[?25l'
#SHOW_CURSOR=$'\e[?25h'

TEST_DIR="_test"
RESULTS_DIR="results"
RESULTS_PATH="/hostlab/$TEST_DIR/$RESULTS_DIR"
DEFAULT_TEST_OUTPUT="$HOSTNAME.default"
USER_TEST_FILE="$HOSTNAME.test"
USER_TEST_OUTPUT="$HOSTNAME.user"

# This function cleans the output of test commands a bit
clean_output() {
   grep -wv grep | \
   grep -wv awk  | \
   grep -wv sed  | \
   grep -wv sort | \
   grep -wv ps | \
   grep -wv tail | \
   grep -v lab-test | \
   grep -wv sleep | \
   sort
}

# This function displays a rolling dot
throbber() {
   FRAMES=(
      [0]=" [    ]"
      [1]=" [.   ]"
      [2]=" [..  ]"
      [3]=" [ .. ]"
      [4]=" [  ..]"
      [5]=" [   .]"
   )
   CURRENT_FRAME=0
   { while true; do
      echo -ne "${FRAMES[$CURRENT_FRAME]}\b\b\b\b\b\b\b"
      sleep 0.3
      CURRENT_FRAME=$(( ($CURRENT_FRAME+1) % 6 ))
   done; } &
   THROBBER_PID=$!
   disown -a
}

# This function stops an existing rolling dot
kill_throbber() {
   kill $THROBBER_PID 2>/dev/null
}

if [ ! -e "/hostlab/$TEST_DIR" ]; then
   echo -e "${BOLD}Lab test directory not available. Giving up.${NORMAL}"
   exit 1
fi

echo -en "${BOLD}Waiting for virtual machines to start...${NORMAL}"
while [ ! -e "/hostlab/readyfor.test" ]; do
   sleep 1
done

echo

[ ! -d "$RESULTS_PATH" ] && mkdir -p "$RESULTS_PATH"
   
############################################
## User defined test
############################################

if [ -x "/hostlab/$TEST_DIR/$HOSTNAME.test" ]; then
   echo -en "${BOLD}Running user-defined test, please wait... "
   throbber
   exec 10>&1 >"$RESULTS_PATH/$USER_TEST_OUTPUT"
   "/hostlab/$TEST_DIR/$USER_TEST_FILE"
else

############################################
## Predefined test
############################################

   echo -en "${BOLD}Waiting 1 minute for the lab to settle...${NORMAL}"
   sleep 10
   echo

   echo -en "${BOLD}Running predefined lab test, please wait... "
   throbber
   exec 10>&1 >"$RESULTS_PATH/$DEFAULT_TEST_OUTPUT"

############################################
## Change the following lines to modify the default test
############################################

   echo '[NETWORK INTERFACES]'
   # MAC addresses may be randomly generated, so they must not be reported
   ip addr show | grep -v ether
   echo

   echo '[ROUTING TABLE]'
   route -n | tail -n +3 | clean_output
   echo

   echo '[LISTENING PORTS]'
   netstat -tuwln  | tail -n +3 | clean_output
   echo

   echo '[PROCESSES]'
   ps -e -o uid,command | tail -n +2 | grep -v "\[" | clean_output
   echo

############################################
## End of the default test
############################################

fi

exec 1>&10 10>&-
kill_throbber
echo -e "\n${BOLD}Test completed.${NORMAL}"
touch "/hostlab/$HOSTNAME.testdone"

# The virtual machine shall now complete the boot phase and keep running,
# thus letting other virtual machines complete their tests on the fully
# running lab. The ltest script should take care of halting this virtual
# machine once all tests have been completed.

