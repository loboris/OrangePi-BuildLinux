#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "Script must be run as root !"
   exit 0
fi

if [ "${1}" = "test" ]; then
    kpackname="opi_kernel-test.tar.gz"
else
    kpackname="opi_kernel.tar.gz"
fi

clear
date
echo -e "\033[36m*********************************************************"
echo "Updating kernel, script.bin and /lib/modules for OrangePI"
echo -e "*********************************************************\033[37m"
setterm -default
echo ""

echo -n "Do you want to download script&kernel package from server, (y/N)?  "
read -n 1 ANSWER

if [ "${ANSWER}" = "y" ] ; then
    echo "."
    echo "Downloading the package ..."
    mkdir /tmp/script_kernel
    wget -O /tmp/script_kernel/${kpackname} http://loboris.eu/${kpackname}
    if [ ! -f /tmp/script_kernel/${kpackname} ]; then
	echo ""
	echo "ERROR downloading the package from server, exiting."
	rm -rf /tmp/script_kernel/*
	rmdir /tmp/script_kernel
	exit 1
    fi

    echo "OK."
    echo -n -e "\033[31m\033[1mUpdate kernel, script.bin and /lib/modules (y/N)?  "
    read -n 1 ANSWER

    echo -e "\033[22m\033[37m"
    setterm -default
    echo ""
    if [ ! "${ANSWER}" = "y" ] ; then
        echo "Aborted."
        rm -rf /boot/lib/* > /dev/null 2>&1
        rmdir /boot/lib > /dev/null 2>&1
        exit 0
    fi

    clear
    mkdir /tmp/script_kernel/files
    cd /tmp/script_kernel/files
    echo "Unpacking ..."
    tar -xf ../${kpackname}
    rm -rf /boot/*
    cp ./* /boot > /dev/null 2>&1
    if [ -d ./lib ]; then
        cp -r ./lib/* /lib > /dev/null 2>&1
        chown -R root:root /lib/modules/* > /dev/null 2>&1
        chown -R root:root /lib/firmware/* > /dev/null 2>&1
    fi
    echo "Files unpacked."
    cd /tmp
    rm -rf /tmp/script_kernel/*
    rmdir /tmp/script_kernel
else
    echo "OK."
    exit 0
fi


echo "=============================================="
echo -e "\033[36mSelect the OrangePI board you want to upgrade:"
setterm -default
echo "  1   OrangePI 2"
echo "  2   OrangePI PLUS"
echo "  3   OrangePI PC"

echo -n "?  "
read -n 1 ANSWER

echo -e "\033[31m\033[1m"
if [ "${ANSWER}" = "1" ] ; then
    echo "Updating OrangePI 2"
    _kernel="_OPI-2"
    _script="OPI-2"
elif [ "${ANSWER}" = "2" ] ; then
    echo "Updating OrangePI PLUS"
    _kernel="_OPI-PLUS"
    _script="OPI-PLUS"
elif [ "${ANSWER}" = "3" ] ; then
    echo "Updating OrangePI PC"
    _kernel="_OPI-2"
    _script="OPI-PC"
else
    echo "No valid board selected, exiting."
    rm -rf /boot/lib/* > /dev/null 2>&1
    rmdir /boot/lib > /dev/null 2>&1
    echo -e "\033[22m\033[37m"
    exit 0
fi

echo -e "\033[22m\033[37m"
setterm -default
echo "==============================="
echo -e "\033[36mSelect hdmi display resolution:"
setterm -default
echo "  1   1080p 60Hz"
echo "  2   1080p 50Hz"
echo "  3    720p 60Hz"
echo "  4    720p 50Hz"

echo -n "?  "
read -n 1 ANSWER

echo ""
echo -e "\033[31m\033[1m"
if [ "${ANSWER}" = "1" ] ; then
    echo "Selected 1080p 60Hz"
    _resol="_1080p60"
elif [ "${ANSWER}" = "2" ] ; then
    echo "Selected 1080p 50Hz"
    _resol="_1080p50"
elif [ "${ANSWER}" = "3" ] ; then
    echo "Selected 720p 60Hz"
    _resol="_720p60"
elif [ "${ANSWER}" = "4" ] ; then
    echo "Selected 720p 50Hz"
    _resol="_720p50"
else
    echo "No valid board selected, exiting."
    rm -rf /boot/lib/* > /dev/null 2>&1
    rmdir /boot/lib > /dev/null 2>&1
    echo -e "\033[22m\033[37m"
    setterm -default
    exit 0
fi

echo -e "\033[22m\033[37m"
setterm -default
echo "====================================="
echo -n -e "\033[36mDo you have HDMI->DVI adapter, (y/N)?  "
read -n 1 ANSWER

echo -e "\033[31m\033[1m"
if [ "${ANSWER}" = "y" ] ; then
    echo "HDMI->DVI interface selected"
    _hdmi="_dvi"
else
    echo "HDMI interface selected"
    _hdmi="_hdmi"
fi

echo -e "\033[22m\033[37m"
setterm -default

echo "================"
echo -n "CONTINUE, (y/N)?  "
read -n 1 ANSWER

echo ""
if [ "${ANSWER}" != "y" ] ; then
    echo "Aborting."
    exit 0
fi

if [ ! -f /boot/uImage${_kernel} ]; then
    echo -e "\033[31m\033[1m"
    echo "ERROR: kernel file \"/boot/uImage${_kernel}\" not found, exiting."
    echo -e "\033[22m\033[37m"
    setterm -default
    exit 1
fi

_fatdir=$(mount | grep /dev/mmcblk0p1 | awk '{print $3}')

if [ ! -d ${_fatdir} ]; then
    echo ""
    echo "Fat partition not mounted, exiting."
fi

cp ${_fatdir}/uImage ${_fatdir}/uImage.bak
cp /boot/uImage${_kernel} ${_fatdir}/uImage

if [ ! -f /boot/script.bin.${_script}${_resol}${_hdmi} ]; then
    echo ""
    echo "ERROR: config file \"/boot/script.bin.${_script}${_resol}${_hdmi}\" not found."
else
    cp ${_fatdir}/script.bin ${_fatdir}/script.bin.bak
	cp /boot/script.bin.${_script}${_resol}${_hdmi} ${_fatdir}/script.bin
fi

echo -e "\033[36m"
echo "kernel, script.bin and /lib/modules updated, please REBOOT."
echo "AFTER REBOOT RUN:  sudo depmod -a"
echo "==========================================================="
echo -e "\033[22m\033[37m"
setterm -default

