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
	@echo "all-really"
	@echo "   Build both the kernel and the filesystem, both for a 32-bit"
	@echo "   architecture and for a 64-bit architecture."
	@echo
	@echo "clean"
	@echo "   A synonym for 'clean-kernel32 clean-kernel64 clean-filesystem32"
	@echo "   clean-filesystem64'"
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

# Following variables contain convenient paths and file names that are 
# frequently used in the following. Their names should be self-explanatory.
NETKIT_HOME:=$(PWD)/..

# Unset any value assigned to the CDPATH environment variable: they may cause
# following 'cd' invocations to move to unexpected directories.
override CDPATH:=

.PHONY: kernel kernel32 kernel64 filesystem filesystem32 filesystem64

all: kernel filesystem
all-really: kernel32 kernel64 filesystem32 filesystem64
all32: kernel32 filesystem32
all64: kernel64 filesystem64

kernel32:
	$(MAKE) TARGET_ARCH=i386 kernel
kernel64:
	$(MAKE) TARGET_ARCH=x86_64 kernel
filesystem32:
	$(MAKE) TARGET_ARCH=i386 filesystem
filesystem64:
	$(MAKE) TARGET_ARCH=x86_64 filesystem

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

###########################################################
#                Kernel-related targets
###########################################################

# Subdirectory where .deb packages will be unpacked
KERNEL_UNPACKED_DEBS_DIR:=$(KERNEL_BUILD_DIR)/debs-unpacked

# Beware: $(shell basename X) and $(basename X) behave differently, especially
# when applied to URLs
KERNEL_PACKAGE_FILE:=$(shell basename $(KERNEL_SOURCE_URL))
# Sample value for KERNEL_PACKAGE_FILE: linux-3.19.3.tar.xz
UNPACKED_KERNEL_DIR:=$(KERNEL_BUILD_DIR)/$(shell echo $(KERNEL_PACKAGE_FILE) | sed -r 's/(\.tar)?\.[^.]+$$//')
# Sample value for UNPACKED_KERNEL_DIR: linux-3.19.3
KERNEL_PATCHES_DIR:=kernel-patches
# Sample value for KERNEL_PATCHES_DIR: kernel-patches
KERNEL_VERSION_NUMBER=$(if $(wildcard $(UNPACKED_KERNEL_DIR)),$(shell make -s -C $(UNPACKED_KERNEL_DIR) kernelversion),)
# Sample value for KERNEL_VERSION_NUMBER: 3.19.3
# Note: getting kernel version number from the package file (or uncompressed directory name)
# is not reliable. For example, the package for kernel 4.0.0 is labelled with version number 4.0.
# Also, KERNEL_VERSION_NUMBER and KERNEL_TARGET_FILE_NAME cannot be simply expanded variables
# (i.e., assigned with `:='), because the kernel directory may not exist yet at this stage.
# The same applies to KERNEL_TARGET_MODULES_DIR.
KERNEL_TARGET_DIR:=$(NETKIT_HOME)/kernel
# Sample value for KERNEL_TARGET_DIR: netkit/kernel
KERNEL_TARGET_FILE_NAME=netkit-kernel-$(KERNEL_VERSION_NUMBER)-$(TARGET_ARCH)
# Sample value for KERNEL_TARGET_FILE_NAME: netkit-kernel-3.19.3-x86_64
KERNEL_TARGET_MODULES_DIR=$(NETKIT_HOME)/kernel/modules-$(KERNEL_VERSION_NUMBER)-$(TARGET_ARCH)
# Sample value for KERNEL_TARGET_MODULES_DIR: netkit/kernel/modules-4.0.0-x86_64

kernel: $(KERNEL_TARGET_DIR)/$(KERNEL_TARGET_FILE_NAME) $(KERNEL_TARGET_MODULES_DIR)/lib/modules/$(KERNEL_VERSION_NUMBER)-netkit/modules.dep

$(KERNEL_TARGET_DIR)/$(KERNEL_TARGET_FILE_NAME): $(UNPACKED_KERNEL_DIR)/vmlinux
	$(call display_message,kernel,"Creating a hard link to the kernel in its default location and enabling it")
	mkdir -p $(KERNEL_TARGET_DIR)
	cp -fl $(UNPACKED_KERNEL_DIR)/vmlinux $(KERNEL_TARGET_DIR)/$(KERNEL_TARGET_FILE_NAME)
	ln -fs $(KERNEL_TARGET_FILE_NAME) $(KERNEL_TARGET_DIR)/netkit-kernel-$(TARGET_ARCH)

$(KERNEL_TARGET_MODULES_DIR)/lib/modules/$(KERNEL_VERSION_NUMBER)-netkit/modules.dep: $(UNPACKED_KERNEL_DIR)/vmlinux
	$(call display_message,kernel,"Moving kernel modules to an appropriate location")
	mkdir -p $(KERNEL_TARGET_MODULES_DIR)
	$(MAKE) -C $(UNPACKED_KERNEL_DIR) ARCH=um SUBARCH=$(TARGET_ARCH) INSTALL_MOD_PATH=$(KERNEL_TARGET_MODULES_DIR) modules_install
	rm -f $(KERNEL_TARGET_MODULES_DIR)/lib/modules/*/{build,source}
# Make sure that the modules.dep file is newer than vmlinux (and do not create
# a modules.dep file if none exists)
	touch -c $(KERNEL_TARGET_MODULES_DIR)/lib/modules/$(KERNEL_VERSION_NUMBER)-netkit/modules.dep

$(UNPACKED_KERNEL_DIR)/vmlinux: $(UNPACKED_KERNEL_DIR)/.config $(KERNEL_UNPACKED_DEBS_DIR)/usr
	$(call display_message,kernel,"Compiling kernel")
# Apparently, using LDFLAGS=-L with the appropriate path does not seem to work
# in the following line. This is why LIBRARY_PATH is used instead.
	$(MAKE) -C $(UNPACKED_KERNEL_DIR) -j $(shell nproc) CFLAGS=-I$(realpath $(KERNEL_UNPACKED_DEBS_DIR)/usr/include) LIBRARY_PATH=$(realpath $(KERNEL_UNPACKED_DEBS_DIR)/usr/lib) ARCH=um SUBARCH=$(TARGET_ARCH) all

$(UNPACKED_KERNEL_DIR)/.config: $(UNPACKED_KERNEL_DIR)/.patched
	$(call display_message,kernel,"Configuring kernel")
	cp $(NETKIT_KERNEL_CONFIG_FILE) $(UNPACKED_KERNEL_DIR)/.config
	make -C $(UNPACKED_KERNEL_DIR) ARCH=um SUBARCH=$(TARGET_ARCH) silentoldconfig

$(UNPACKED_KERNEL_DIR)/.patched: $(UNPACKED_KERNEL_DIR)/Makefile
	$(call display_message,kernel,"Applying Netkit-specific kernel patches")
	for DIFF_FILE in $(KERNEL_PATCHES_DIR)/*.diff; do patch -p1 -d $(UNPACKED_KERNEL_DIR) < $$DIFF_FILE; done
	touch $(UNPACKED_KERNEL_DIR)/.patched

$(UNPACKED_KERNEL_DIR)/Makefile: $(KERNEL_PACKAGE_FILE)
	$(call display_message,kernel,"Unpacking kernel source package")
	mkdir -p $(KERNEL_BUILD_DIR)
	tar -xJC $(KERNEL_BUILD_DIR) -f $<
# Make sure the Makefile is newer than the kernel package (and do not
# create a Makefile if there is none)
	touch -c $(UNPACKED_KERNEL_DIR)/Makefile

$(KERNEL_PACKAGE_FILE):
	$(call display_message,kernel,"Downloading kernel source package")
# Here --no-use-server-timestamps is used in order to make sure that
# the last changed date of the kernel package is the current time
# (required for proper detection of prerequisite "freshness")
	wget --progress=bar --no-use-server-timestamps $(KERNEL_SOURCE_URL)

$(KERNEL_UNPACKED_DEBS_DIR)/usr:
	$(call display_message,kernel,"Downloading and extracting support libraries required for kernel compilation")
	mkdir -p $(KERNEL_UNPACKED_DEBS_DIR); rm -f $(KERNEL_BUILD_DIR)/*.deb
	wget -P $(KERNEL_BUILD_DIR) --progress=bar $(HEADER_LIBRARY_DEBS_URL)
	for DEB_FILE in $(KERNEL_BUILD_DIR)/*.deb; do dpkg-deb -x $$DEB_FILE $(KERNEL_UNPACKED_DEBS_DIR); done



###########################################################
#                Filesystem-related targets
###########################################################

# Temporary compressed file where base .deb packages for building the filesystem
# image will be stored
FILESYSTEM_BASEPACKAGES_ARCHIVE:=base-deb-packages-$(TARGET_ARCH)

FILESYSTEM_TWEAKS_DIR:=fs-tweaks
# Sample value for FILESYSTEM_TWEAKS_DIR: fs-tweaks
FILESYSTEM_PACKAGES_DEBCONF:=netkit-fs-debconf
# Sample value for FILESYSTEM_PACKAGES_DEBCONF: netkit-fs-debconf
FILESYSTEM_PACKAGES_LIST_FROM_VM:=/tmp/netkit-package-list
# Sample value for FILESYSTEM_PACKAGES_LIST_FROM_VM: /tmp/netkit-package-list

FILESYSTEM_TARGET_DIR:=$(NETKIT_HOME)/fs
# Sample value for FILESYSTEM_TARGET_DIR: netkit/fs
FILESYSTEM_TARGET_FILE_NAME:=netkit-fs-$(DEBIAN_RELEASE)-$(TARGET_ARCH)
# Sample value for FILESYSTEM_TARGET_FILE_NAME: netkit-fs-sid-x86_64
FILESYSTEM_MOUNT_DIR:=$(FILESYSTEM_BUILD_DIR)/temp-fs-mount
# Sample value for FILESYSTEM_MOUNT_DIR: fs-build-x86_64/temp-fs-mount


# Architecture names are slightly different in Debian mirrors
TARGET_FS_ARCH:=$(TARGET_ARCH)
ifeq ($(TARGET_ARCH),x86_64)
TARGET_FS_ARCH:=amd64
endif


# Isolate the steps in the build procedure that require root privileges to be
# executed
ifeq ($(shell whoami),root)
filesystem: $(FILESYSTEM_MOUNT_DIR)
	$(call display_message,filesystem,"You can now continue the build as a standard user: just reinvoke the Makefile on the same filesystem target\(s\) specifying STAGE=2.")
else
ifeq ($(STAGE),2)
filesystem: $(FILESYSTEM_TARGET_DIR)/$(FILESYSTEM_TARGET_FILE_NAME)
else
filesystem: $(FILESYSTEM_MOUNT_DIR)
endif
endif

$(FILESYSTEM_TARGET_DIR)/$(FILESYSTEM_TARGET_FILE_NAME): .filesystem-setup-complete
	$(call display_message,filesystem,"Sparsifying filesystem image and moving it to its default location")
	mkdir -p $(FILESYSTEM_TARGET_DIR)
	cp --sparse=always -f $(FILESYSTEM_BUILD_DIR)/temp-fs-$(TARGET_ARCH).img $(FILESYSTEM_TARGET_DIR)/$(FILESYSTEM_TARGET_FILE_NAME)
	rm -f $(FILESYSTEM_BUILD_DIR)/temp-fs-$(TARGET_ARCH).img
	$(call display_message,filesystem,"Saving list of packages")
	mv $(FILESYSTEM_PACKAGES_LIST_FROM_VM) $(FILESYSTEM_TARGET_DIR)/$(FILESYSTEM_TARGET_FILE_NAME)-packages.lst

.filesystem-setup-complete: slirp $(FILESYSTEM_BUILD_DIR)/temp-fs-$(TARGET_ARCH).img
	$(call display_message,filesystem,"Continuing filesystem setup inside virtual machine")
	$(NETKIT_HOME)/kernel/netkit-kernel-$(TARGET_ARCH) umid=netkit-setup-vm mem=1G ubd0=$(FILESYSTEM_BUILD_DIR)/temp-fs-$(TARGET_ARCH).img con=null con0=fd:0,fd:1 eth0=slirp,,$(realpath ./slirp) quiet systemd.show_status=1
	[ ! -f /tmp/.netkit-setup-running ]

$(FILESYSTEM_MOUNT_DIR): $(FILESYSTEM_BUILD_DIR)/temp-fs-$(TARGET_ARCH).img

$(FILESYSTEM_BUILD_DIR)/temp-fs-$(TARGET_ARCH).img: $(FILESYSTEM_BUILD_DIR) $(FILESYSTEM_BUILD_DIR)/$(FILESYSTEM_BASEPACKAGES_ARCHIVE).tgz
# This is the only phase that unavoidably requires root privileges (note:
# working with fakeroot and fakechroot does not produce a working filesystem
# image, at the very least because file ownerships are only simulated and not
# really written to the filesystem).
ifneq ($(shell whoami),root)
	$(call display_message,filesystem,"Please re-invoke the Makefile as root on the same target\(s\): $(MAKECMDGOALS).")
else    # ifneq ($(shell whoami),root)
	$(call display_message,filesystem,"Installing base packages in the filesystem image")
	mkdir -p $(FILESYSTEM_MOUNT_DIR)
## The following command succeeds both if the filesystem is correctly mounted
## (mount return success) and if the filesystem was already mounted (mount fails,
## but mountpoint returns success), which may for example be the case if the
## Makefile was previously interrupted.
#	mount -o loop $(FILESYSTEM_BUILD_DIR)/temp-fs-$(TARGET_ARCH).img $(FILESYSTEM_MOUNT_DIR) || mountpoint $(FILESYSTEM_MOUNT_DIR)
	$(DEBOOTSTRAP) --unpack-tarball=$(realpath $(FILESYSTEM_BUILD_DIR)/$(FILESYSTEM_BASEPACKAGES_ARCHIVE).tgz) --arch=$(TARGET_FS_ARCH) --include=debconf-utils $(DEBIAN_RELEASE) $(FILESYSTEM_MOUNT_DIR) $(DEBIAN_MIRROR)
# Prepare a list of APT sources based on the official list of primary Debian mirrors
	mkdir -p $(FILESYSTEM_MOUNT_DIR)/etc/apt
	wget --no-verbose -O - "http://ftp.it.debian.org/debian/README.mirrors.txt" | sed -n '/Primary/,/Secondary/p' | awk '/i386/ {split(substr($$0,match($$0,/ftp/)),a); print "# deb http://" a[1] a[2] " $(DEBIAN_RELEASE) main contrib non-free"}' | sed '/ftp\.it/ s/^# //' > $(FILESYSTEM_MOUNT_DIR)/etc/apt/sources.list
	cp -rd $(FILESYSTEM_TWEAKS_DIR)/* $(FILESYSTEM_MOUNT_DIR)
	cp $(FILESYSTEM_PACKAGES_DEBCONF) $(FILESYSTEM_MOUNT_DIR)
	ln -s /etc/systemd/netkit/netkit-setup.service $(FILESYSTEM_MOUNT_DIR)/etc/systemd/system/multi-user.target.wants
#	umount $(FILESYSTEM_MOUNT_DIR)
## Since the filesystem image has now been more recently updated than the
## filesystem mount directory, we need to touch the latter
	$(call display_message,filesystem,"Creating filesystem image")
	virt-make-fs --format=raw --size=$(FILESYSTEM_IMAGE_SIZE) --type=$(FILESYSTEM_TYPE) $(FILESYSTEM_MOUNT_DIR) $(FILESYSTEM_BUILD_DIR)/temp-fs-$(TARGET_ARCH).img
	chmod a+rw $(FILESYSTEM_BUILD_DIR)/temp-fs-$(TARGET_ARCH).img
#	touch $(FILESYSTEM_MOUNT_DIR)
endif

slirp:
	$(call display_message,filesystem,"Downloading and compiling the slirp tool \(required for virtual machine Internet connectivity\)")
	mkdir -p $(FILESYSTEM_BUILD_DIR)/slirp/
	cd $(FILESYSTEM_BUILD_DIR)/slirp/ && apt-get source slirp
# UML converts underscores in the slirp command line to spaces
# (see http://ptgmedia.pearsoncmg.com/images/9780131865051/downloads/013865056_Dike_book.pdf)
# Copying the slirp binary to the current directory reasonably ensures that the
# path to reach it does not contain underscores.
	cd $(FILESYSTEM_BUILD_DIR)/slirp/slirp-*/src && ./configure && make CFLAGS="-I. -DUSE_PPP -DUSE_MS_DNS -DFULL_BOLT"
	cp -fl $(FILESYSTEM_BUILD_DIR)/slirp/slirp-*/src/slirp . && touch slirp

$(FILESYSTEM_BUILD_DIR)/$(FILESYSTEM_BASEPACKAGES_ARCHIVE).tgz:
	$(call display_message,filesystem,"Downloading packages for minimal Debian installation")
# Simply downloading .deb packages should not really require root privileges, so
# we use fakeroot here
	$(FAKEROOT) $(DEBOOTSTRAP) --download-only --arch=$(TARGET_FS_ARCH) --make-tarball=$(FILESYSTEM_BUILD_DIR)/$(FILESYSTEM_BASEPACKAGES_ARCHIVE)-$(TIMESTAMP).tgz --include=debconf-utils $(DEBIAN_RELEASE) $(FILESYSTEM_MOUNT_DIR) $(DEBIAN_MIRROR)
	rm -fr $(FILESYSTEM_MOUNT_DIR)
	ln -fs $(FILESYSTEM_BASEPACKAGES_ARCHIVE)-$(TIMESTAMP).tgz $(FILESYSTEM_BUILD_DIR)/$(FILESYSTEM_BASEPACKAGES_ARCHIVE).tgz

$(FILESYSTEM_BUILD_DIR):
	mkdir -p $(FILESYSTEM_BUILD_DIR)

#$(FILESYSTEM_BUILD_DIR)/temp-fs-$(TARGET_ARCH).img: $(FILESYSTEM_BUILD_DIR)
#	$(call display_message,filesystem,"Creating empty filesystem")
#	dd if=/dev/zero of=$(FILESYSTEM_BUILD_DIR)/temp-fs-$(TARGET_ARCH).img bs=1 count=0 seek=$(FILESYSTEM_IMAGE_SIZE)
#	$(LOSETUP) $(LOOP_DEVICE) $(FILESYSTEM_BUILD_DIR)/temp-fs-$(TARGET_ARCH).img
#	$(MKFS) -L "Netkit FS" -t $(FILESYSTEM_TYPE) $(LOOP_DEVICE)
#	$(LOSETUP) -d $(LOOP_DEVICE)

##############################################################################
##############################################################################

clean: clean-kernel32 clean-kernel64 clean-filesystem32 clean-filesystem64

clean-kernel32:
	$(MAKE) TARGET_ARCH=i386 clean-kernel
clean-kernel64:
	$(MAKE) TARGET_ARCH=x86_64 clean-kernel
clean-filesystem32:
	$(MAKE) TARGET_ARCH=i386 clean-filesystem
clean-filesystem64:
	$(MAKE) TARGET_ARCH=x86_64 clean-filesystem

clean-kernel:
	rm -fr $(KERNEL_BUILD_DIR) $(KERNEL_PACKAGE_FILE)
clean-filesystem:
	rm -fr $(FILESYSTEM_BUILD_DIR) slirp .filesystem-setup-complete

