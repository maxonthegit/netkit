#     This Makefile allows to rebuild the kernel, the filesystem image, and the
#     userspace tools that are part of Netkit, a network emulation environment
#     based on the integration of several existing pieces of software.
#     For more information: http://www.netkit.org/
#
#     Copyright (C) 2015  Massimo Rimondini (rimondini@ing.uniroma3.it)
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

SHELL=/bin/bash

# Variable: TARGET_ARCH
# Must be either "x86_64" or "i386", depending on the target architecture Netkit
# is to be built for. Example:
# TARGET_ARCH?=x86_64
TARGET_ARCH?=$(shell arch)
ifeq ($(TARGET_ARCH),i686)
TARGET_ARCH=i386
endif
ifeq ($(TARGET_ARCH),i586)
TARGET_ARCH=i386
endif

ifeq ($(TARGET_ARCH),i386)
TARGET_ARCH_DEBIAN:=i386
else ifeq ($(TARGET_ARCH),x86_64)
TARGET_ARCH_DEBIAN:=amd64
else
$(error Invalid target architecture: $(TARGET_ARCH) (only i386 and x86_64 are supported))
endif

# Variable: TOOLS_BUILD_DIR
# Specifies the name of the directory where work files for building
# command line tools will be kept. It should always be an absolute path.
# Example:
# TOOLS_BUILD_DIR:=$(CURDIR)/bintools-build
TOOLS_BUILD_DIR:=$(CURDIR)/bintools-build-$(TARGET_ARCH)



##############################################################################
##############################################################################


help:
	@echo 
	@echo "This Makefile is meant to be used by developers and/or advanced users to"
	@echo "build custom kernel binaries or filesystem images to be used with Netkit."
	@echo
	@echo "Available targets are:"
	@echo
	@echo "bintools"
	@echo "   Generate any command line and Netkit-specific support tools that"
	@echo "   are supposed to be built from source code."
	@echo
	@echo "kernel"
	@echo "   Build a user-mode Linux kernel to be used with Netkit. The kernel"
	@echo "   source, as well as a few auxiliary header files, are automatically"
	@echo "   downloaded; any applicable patches are also automatically applied."
	@echo "   The generated kernel executable file, as well as the associated"
	@echo "   kernel modules, will be put inside the kernel/ subdirectory in the"
	@echo "   parent of this build directory tree."
	@echo
	@echo "filesystem"
	@echo "   Build a Debian filesystem image to be used with Netkit. Any"
	@echo "   relevant pieces of software are automatically downloaded. A"
	@echo "   pre-compiled binary UML kernel will be downloaded during the"
	@echo "   procedure in order to accomplish some tasks that would require"
	@echo "   additional privileges on the host."
	@echo "   Note: a properly working Netkit kernel must be available in order"
	@echo "   to be able to build the filesystem image."
	@echo "   The generated filesystem image will be put inside the fs/"
	@echo "   subdirectory in the parent of this build directory tree."
	@echo
	@echo "all"
	@echo "   Build both the kernel and the filesystem."
	@echo 
	@echo "clean-bintools"
	@echo "clean-kernel"
	@echo "clean-filesystem"
	@echo "   Clean any intermediate and final products of the respective build"
	@echo "   processes. Using 'clean' as a target is a shortcut for 'clean-bintools"
	@echo "   clean-kernel clean-filesystem'."
	@echo
	@echo "clean"
	@echo "   Clean all of the above."
	@echo 
	@echo "By default, the Makefile performs a build for a target architecture"
	@echo "that matches the host architecture (that is, if the Makefile is run"
	@echo "on a 64-bit host, it will build a 64-bit kernel and a 64-bit filesystem"
	@echo "image). The target architecture can be forced by using variable"
	@echo "TARGET_ARCH, which has two possible values: 'i386' and 'x86_64'."
	@echo "Alternatively, any of the above targets can be invoked with suffix '32'"
	@echo "or '64' to force a build for 32-bit or 64-bit architectures, respectively."
	@echo "Using 'make kernel32' or 'make TARGET_ARCH=i386 kernel' is equivalent."
	@echo
	@echo "everything"
	@echo "   Build any relevant command line tools, the kernel, and the"
	@echo "   filesystem, both for a 32-bit architecture and for a 64-bit"
	@echo "   architecture."
	@echo 
	@echo "clean-everything"
	@echo "   A synonym for 'clean32 clean64'."
	@echo
	@echo "The following variables can be specified on the make command line in"
	@echo "order to tune the build process:"
	@echo
	@echo "   TARGET_ARCH (default: $(TARGET_ARCH))"
	@echo "      Can be either 'i386' or 'x86_64'. Determines the architecture"
	@echo "      for which kernel and filesystem are built."
	@echo "   KERNEL_SOURCE_URL (default: $(KERNEL_SOURCE_URL))"
	@echo "      URL of the kernel source package."
	@echo "   DEBIAN_MIRROR (default: $(DEBIAN_MIRROR))"
	@echo "      Debian mirror from which any Debian packages should be obtained."
	@echo "      It is also used during kernel compilation to retrieve some"
	@echo "      required header files and libraries."
	@echo "   DEBIAN_RELEASE (default: $(DEBIAN_RELEASE))"
	@echo "      Name of the Debian version to be installed in the filesystem"
	@echo "      image."
	@echo "   FILESYSTEM_IMAGE_SIZE (default: $(FILESYSTEM_IMAGE_SIZE))"
	@echo "      Total size of the generated filesystem image (the space actually"
	@echo "      consumed on disk is smaller because a sparse file is used for"
	@echo "      the image). The following multiplicative suffixes can be used:"
	@echo "      K, M, G, T, P, E, Z, Y."
	@echo




##############################################################################
## The actual build procedure follows. End users would expectedly never need
## to change the following lines.
##############################################################################

define display_message
	@echo -e "\e[32;1m[$(1) $(TARGET_ARCH)]\e[0;1m $(2)\e[0m"
endef

# Disable built-in rules
MAKEFLAGS+=-r

NETKIT_HOME:=$(CURDIR)/..

# Unset any value assigned to the CDPATH environment variable: they may cause
# following 'cd' invocations to move to unexpected directories.
override CDPATH:=

# The following variable points to a directory that contains patches that must
# be applied to software pieces other than the UML kernel. It should always
# be an absolute path.
# Example:
# OTHER_PATCHES_DIR:=$(CURDIR)/other-patches
OTHER_PATCHES_DIR:=$(CURDIR)/other-patches

.PHONY: bintools bintools32 bintools64 kernel kernel32 kernel64 filesystem filesystem32 filesystem64

all: bintools kernel filesystem
all32: bintools32 kernel32 filesystem32
all64: bintools64 kernel64 filesystem64
everything: all32 all64

bintools32:
	$(MAKE) TARGET_ARCH=i386 bintools
bintools64:
	$(MAKE) TARGET_ARCH=x86_64 bintools
kernel32:
	$(MAKE) TARGET_ARCH=i386 kernel
kernel64:
	$(MAKE) TARGET_ARCH=x86_64 kernel
filesystem32:
	$(MAKE) TARGET_ARCH=i386 filesystem
filesystem64:
	$(MAKE) TARGET_ARCH=x86_64 filesystem

ifeq ($(TARGET_ARCH),i386)
COMPILE_FLAGS=-m32
else
COMPILE_FLAGS=-m64
endif

TIMESTAMP:=$(shell date +%Y%m%d-%H%M%S)

check_not_empty=$(if $(1),$(1),$(error $(2)))

find_command_actual=$(word 1,$(shell whereis -b $(1) | tr ' ' '\n' | tail -n +2 | egrep --color=never "$(1)( |$$)"))
find_command=$(call check_not_empty,$(call find_command_actual,$(1)),Command not found: $(1))

# The following assignemnts are used to mount the filesystem image using a
# loopback device
LOSETUP=$(call find_command,losetup)
LOOP_DEVICE=$(call check_not_empty,$(shell $(LOSETUP) -f),Not enough permissions to access loop devices)


TOOLS_DIR:=$(NETKIT_HOME)/bin
# Sample value for TOOLS_DIR: netkit/bin

ifeq ($(TARGET_ARCH),i386)
TOOLS_ARCH_DIR:=$(NETKIT_HOME)/bin/32bit
else
TOOLS_ARCH_DIR:=$(NETKIT_HOME)/bin/64bit
endif
# Sample value for TOOLS_ARCH_DIR: netkit/bin/64bit


###########################################################
#                 Kernel-related targets
###########################################################

include Makefile.kernel

###########################################################
#               Filesystem-related targets
###########################################################

include Makefile.filesystem

###########################################################
#              Targets for command line tools
###########################################################

bintools: $(TOOLS_ARCH_DIR)/slirp

include Makefile.slirp


##############################################################################
##############################################################################

clean: clean-bintools clean-kernel clean-filesystem
clean32: clean-bintools32 clean-kernel32 clean-filesystem32
clean64: clean-bintools64 clean-kernel64 clean-filesystem64

clean-everything: clean32 clean64

clean-bintools:
	rm -fr $(TOOLS_BUILD_DIR)

clean-bintools32:
	$(MAKE) TARGET_ARCH=i386 clean-bintools
clean-bintools64:
	$(MAKE) TARGET_ARCH=x86_64 clean-bintools
clean-kernel32:
	$(MAKE) TARGET_ARCH=i386 clean-kernel
clean-kernel64:
	$(MAKE) TARGET_ARCH=x86_64 clean-kernel
clean-filesystem32:
	$(MAKE) TARGET_ARCH=i386 clean-filesystem
clean-filesystem64:
	$(MAKE) TARGET_ARCH=x86_64 clean-filesystem

