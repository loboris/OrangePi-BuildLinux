#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "Script must be run as root !"
   exit 0
fi

echo ""
date
echo "************************************"
echo "Updating boot0 & u-boot for OrangePI"
echo "************************************"
echo ""

echo -n "Do you want to download boot&kernel package from server, (y/N)?  "
read -n 1 ANSWER

if [ "${ANSWER}" = "y" ] ; then
    echo "."
    echo "Downloading the package ..."
    mkdir /tmp/script_kernel
    wget -O /tmp/script_kernel/script_kernel.tar.gz http://loboris.eu/script_kernel.tar.gz
    if [ ! -f /tmp/script_kernel/script_kernel.tar.gz ]; then
		echo ""
		echo "ERROR downloading the package from server, exiting."
		rm -rf /tmp/script_kernel/*
		rmdir /tmp/boot_kernel
		exit 1
    fi
    mkdir /tmp/script_kernel/files
    cd /tmp/script_kernel/files
    echo "Unpacking ..."
    tar -xf ../script_kernel.tar.gz
    cp -v ./* /boot
    echo "Files unpacked to /boot"
    echo "======================="
    echo ""
    cd /tmp
    rm -rf /tmp/script_kernel/*
    rmdir /tmp/script_kernel
else
    echo "."
    echo "Using existing files."
fi


echo ""
echo "=============================================="
echo "Select the OrangePI board you want to upgrade:"
echo "  1   OrangePI 2"
echo "  2   OrangePI PLUS"
echo "  3   OrangePI PC"

echo -n "?  "
read -n 1 ANSWER

if [ "${ANSWER}" = "1" ] ; then
    echo "."
    echo ""
    echo "Updating OrangePI 2"
    _kernel="_OPI-2"
    _script="OPI-2"
elif [ "${ANSWER}" = "2" ] ; then
    echo "."
    echo ""
    echo "Updating OrangePI PLUS"
    _kernel="_OPI-PLUS"
    _script="OPI-PLUS"
elif [ "${ANSWER}" = "3" ] ; then
    echo "."
    echo ""
    echo "Updating OrangePI PC"
    _kernel="_OPI-2"
    _script="OPI-PC"
else
    echo ""
    echo "No valid board selected, exiting."
    exit 0
fi

echo ""
echo "==============================="
echo "Select hdmi display resolutuin:"
echo "  1   1080p 60Hz"
echo "  2   1080p 50Hz"
echo "  3    720p 60Hz"
echo "  4    720p 50Hz"

echo -n "?  "
read -n 1 ANSWER

if [ "${ANSWER}" = "1" ] ; then
    echo "."
    echo ""
    echo "Selected 1080p 60Hz"
    _resol="_1080p60"
elif [ "${ANSWER}" = "2" ] ; then
    echo "."
    echo ""
    echo "Selected 1080p 50Hz"
    _resol="_1080p50"
elif [ "${ANSWER}" = "3" ] ; then
    echo "."
    echo ""
    echo "Selected 720p 60Hz"
    _resol="_72p60"
elif [ "${ANSWER}" = "4" ] ; then
    echo "."
    echo ""
    echo "Selected 720p 50Hz"
    _resol="_72p50"
else
    echo ""
    echo "No valid board selected, exiting."
    exit 0
fi

echo ""
echo -n "WARNING: boot0 & u-boot on /dev/mmcblk0 WILL BE REPLACED, Continue (y/N)?  "
read -n 1 ANSWER

if [ "${ANSWER}" = "y" ] ; then
    if [ ! -f /boot/boot0_OPI.fex ] || [ ! -f /boot/u-boot_OPI.fex ]; then
	echo ""
	echo "ERROR: boot file \"/boot/boot0_OPI.fex\" or \"/boot/u-boot_OPI.fex\" not found, not updated."
    else
	echo ""
	echo "Writing boot files to /dev/mmcblk0 ..."

	dd if=/boot/boot0_OPI.fex of=/dev/mmcblk0 bs=1k seek=8
	dd if=/boot/u-boot_OPI.fex of=/dev/mmcblk0 bs=1k seek=16400
	
	echo ""
	echo "Boot files updated, please REBOOT."
	echo "=================================="
    fi
else
    echo "."
    echo "Boot files not updated."
fi

echo ""
echo -n "Do you want to write the new kernel (uImage) to fat partition (y/N)?  "
read -n 1 ANSWER

if [ ! "${ANSWER}" = "y" ] ; then
    echo "."
    echo ""
    echo "uImage not updated."
    exit 0
fi

echo ""
if [ ! -f /boot/uImage${_kernel} ]; then
    echo ""
    echo "ERROR: kernel file \"/boot/uImage${_kernel}\" not found, exiting."
    exit 1
fi

_fatdir=$(mount | grep /dev/mmcblk0p1 | awk '{print $3}')

if [ ! -d ${_fatdir} ]; then
    echo ""
    echo "Fat partition not mounted, exiting"
fi

cp /boot/uImage${_kernel} ${_fatdir}/uImage

if [ ! -f /boot/script.bin.${_script}${_resol} ]; then
    echo ""
    echo "WARNING: config file \"/boot/script.bin.{_script}${_resol}\" not found."
else
	cp /boot/script.bin.${_kernel} ${_fatdir}/script.bin
fi

echo ""
echo "uImage updated, please REBOOT."
echo "=============================="
echo ""
