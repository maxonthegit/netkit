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

# Variable: DEBIAN_MIRROR
# Base URL of the Debian mirror to be used when retrieving packages, without
# final '/'. Example:
# DEBIAN_MIRROR?=http://ftp.it.debian.org/debian
DEBIAN_MIRROR?=http://ftp.it.debian.org/debian

# Variable: KERNEL_SOURCE_URL
# Specifies where to get the kernel source package from. Example:
# KERNEL_SOURCE_URL?=https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.19.3.tar.xz
KERNEL_SOURCE_URL?=https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.0.tar.xz

# Variable: NETKIT_KERNEL_CONFIG_FILE
# Specifies the name of the file containing the Netkit-specific kernel
# configuration. Example:
# NETKIT_KERNEL_CONFIG_FILE:=netkit-kernel-config-3.19.3-x86_64
NETKIT_KERNEL_CONFIG_FILE:=$(wildcard netkit-kernel-config-*-$(TARGET_ARCH))

# Variable: KERNEL_BUILD_DIR
# Specifies the name of the directory where the kernel will be built. It is
# usually a relative path, but absolute paths should work as well. Example:
# KERNEL_BUILD_DIR:=kernel-build
KERNEL_BUILD_DIR:=kernel-build-$(TARGET_ARCH)

# Variable: HEADER_LIBRARY_DEBS_URL
# Space-separated list of URLs pointing to .deb packages that contain header
# files and libraries required to successfully compile the kernel. They will
# *not* be actually installed, but just decompressed in order to retrieve the
# required files. Different .deb packages may be required depending on the
# target architecture Netkit is being built for. Example:
# HEADER_LIBRARY_DEBS_URL=$(DEBIAN_MIRROR)/debian/pool/main/v/vde2/libvdeplug-dev_2.3.2+r586-2_amd64.deb
ifeq ($(TARGET_ARCH),x86_64)
HEADER_LIBRARY_DEBS_URL:=$(DEBIAN_MIRROR)/pool/main/v/vde2/libvdeplug-dev_2.3.2+r586-2_amd64.deb $(DEBIAN_MIRROR)/pool/main/libp/libpcap/libpcap0.8-dev_1.6.2-2_amd64.deb
else
HEADER_LIBRARY_DEBS_URL:=$(DEBIAN_MIRROR)/pool/main/v/vde2/libvdeplug-dev_2.3.2+r586-2_i386.deb $(DEBIAN_MIRROR)/pool/main/libp/libpcap/libpcap0.8-dev_1.6.2-2_i386.deb
endif

# Variable: DEBIAN_RELEASE
# Specifies the name of the Debian release that should be installed in the
# filesystem image. Available names can be found at
# https://www.debian.org/releases/. Example:
# DEBIAN_RELEASE?=sid
DEBIAN_RELEASE?=sid

# Variable: FILESYSTEM_IMAGE_SIZE
# Specifies the amount of available space inside the filesystem image (since
# it is created as a sparse file, this does not correspond to actual physical
# disk space consumption). Suffixes such as K, M, and G, are supported. Example:
# FILESYSTEM_IMAGE_SIZE?=20G
FILESYSTEM_IMAGE_SIZE?=20G

# Variable: FILESYSTEM_BUILD_DIR
# Specifies the name of the directory where work files for building the
# filesystem image will be kept. It is usually a relative path, but absolute
# paths should work as well. Example:
# FILESYSTEM_BUILD_DIR:=fs-build
FILESYSTEM_BUILD_DIR:=fs-build-$(TARGET_ARCH)

# Variable: TOOLS_BUILD_DIR
# Specifies the name of the directory where work files for building
# command line tools will be kept. It is usually a relative path, but absolute
# paths should work as well. Example:
# TOOLS_BUILD_DIR:=bintools-build
TOOLS_BUILD_DIR:=bintools-build-$(TARGET_ARCH)



##############################################################################
##############################################################################


help:
	@echo 
	@echo "This Makefile is meant to be used by developers and/or advanced users to"
	@echo "build custom kernel binaries or filesystem images to be used with Netkit."
	@echo
	@echo "Available targets are:"
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
	@echo "   relevant pieces of software are automatically downloaded. Some build"
	@echo "   steps require root privileges: a suitable message will ask you"
	@echo "   to re-run the Makefile as root. After these steps are accomplished,"
	@echo "   the build can continue with standard user privileges: another"
	@echo "   message will ask you to re-run the Makefile for the final stage."
	@echo "   Note: a properly working Netkit kernel must be available in order"
	@echo "   to be able to build the filesystem image."
	@echo "   The generated filesystem image will be put inside the fs/"
	@echo "   subdirectory in the parent of this build directory tree."
	@echo
	@echo "all"
	@echo "   Build both the kernel and the filesystem."
	@echo 
	@echo "clean-kernel"
	@echo "clean-filesystem"
	@echo "   Clean any intermediate and final products of the respective build"
	@echo "   processes."
	@echo 
	@echo "By default, the Makefile performs a build for a target architecture"
	@echo "that matches the host architecture (that is, if the Makefile is run"
	@echo "on a 64-bit host, it will build a 64-bit kernel and a 64-bit filesystem"
	@echo "image). The target architecture can be forced by using variable"
	@echo "TARGET_ARCH, which has two possible values: 'i386' and 'amd64'. All the"
	@echo "above targets can be invoked with suffix '32' or '64' to force a build"
	@echo "for 32-bit or 64-bit architectures, respectively. Using 'make kernel32'"
	@echo "or 'make TARGET_ARCH=i386 kernel' is equivalent."
	@echo
	@echo "everything"
	@echo "   Build both the kernel and the filesystem, both for a 32-bit"
	@echo "   architecture and for a 64-bit architecture. This is a shortcut for"
	@echo "   the typical 'build everything' pipeline:"
	@echo "   make kernel32 kernel64 filesystem32 filesystem64 && \\"
	@echo "   sudo make filesystem32 filesystem64 && \\"
	@echo "   make filesystem32 filesystem64 STAGE=2"
	@echo "   Users invoking this target should have adequate privileges"
	@echo "   set up in the sudoers file."
	@echo 
	@echo "clean"
	@echo "   A synonym for 'clean-kernel32 clean-kernel64 clean-filesystem32"
	@echo "   clean-filesystem64'."
	@echo
	@echo "The following variables can be specified on the make command line in"
	@echo "order to tune the build process:"
	@echo
	@echo "   TARGET_ARCH (default: $(TARGET_ARCH))"
	@echo "      Can be either 'i386' or 'x64_64'. Determines the architecture"
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

# Following variables contain convenient paths and file names that are 
# frequently used in the following. Their names should be self-explanatory.
NETKIT_HOME:=$(PWD)/..

# Unset any value assigned to the CDPATH environment variable: they may cause
# following 'cd' invocations to move to unexpected directories.
override CDPATH:=

.PHONY: kernel kernel32 kernel64 filesystem filesystem32 filesystem64

all: bintools kernel filesystem
all32: kernel32 filesystem32
all64: kernel64 filesystem64
everything: bintools32 bintools64 kernel32 kernel64 filesystem32 filesystem64
	sudo $(MAKE) filesystem32 filesystem64
	$(MAKE) STAGE=2 filesystem32 filesystem64

kernel32:
	$(MAKE) TARGET_ARCH=i386 kernel
kernel64:
	$(MAKE) TARGET_ARCH=x86_64 kernel
filesystem32:
	$(MAKE) TARGET_ARCH=i386 filesystem
filesystem64:
	$(MAKE) TARGET_ARCH=x86_64 filesystem
bintools32:
	$(MAKE) TARGET_ARCH=i386 bintools
bintools64:
	$(MAKE) TARGET_ARCH=x86_64 bintools

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

# The following assignment determines the filesystem type used inside the
# Netkit filesystem image
FILESYSTEM_TYPE:=ext4
MKFS=$(call find_command,mkfs)

DEBOOTSTRAP=$(call find_command,debootstrap)
FAKEROOT=$(call find_command,fakeroot)

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

clean-everything: clean-bintools32 clean-bintools64 clean-kernel32 clean-kernel64 clean-filesystem32 clean-filesystem64

clean-bintools:
	rm -fr $(TOOLS_BUILD_DIR)

clean-kernel32:
	$(MAKE) TARGET_ARCH=i386 clean-kernel
clean-kernel64:
	$(MAKE) TARGET_ARCH=x86_64 clean-kernel
clean-filesystem32:
	$(MAKE) TARGET_ARCH=i386 clean-filesystem
clean-filesystem64:
	$(MAKE) TARGET_ARCH=x86_64 clean-filesystem
clean-bintools32:
	$(MAKE) TARGET_ARCH=i386 clean-bintools
clean-bintools64:
	$(MAKE) TARGET_ARCH=x86_64 clean-bintools

