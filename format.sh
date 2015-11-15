#!/bin/bash

if [ "${_format}" = "btrfs" ]; then
    # WE MUST USE FAT PARTITION TO BOOT IF BTRFS IS USED
    _boot_on_ext4="no"
fi

# ======================================================================
# IF CREATING ON IMMAGE, PREPARE SD CARD IMAGE FOR ORANGEPI - LINUX BOOT
# ----------------------------------------------------------------------
# === CHECK DESTINATION ============================================
if [ ! "${image_name}" = "" ]; then
    rm ${sdcard}1 > /dev/null 2>&1
    rm ${sdcard}2 > /dev/null 2>&1
    rm ${sdcard}u > /dev/null 2>&1
    if [ -b $image_name ]; then
        # === ON BLOCK DEVICE ======================================
        echo "Creating filesystem on block device ${image_name} ..."
        sdcard="$image_name"
        _directsd="yes"
        _ddparm=""
        # ==========================================================
    else
        # === ON IMAGE FILE ======================
        if [ "${_boot_on_ext4}" = "yes" ] ; then
            sdcard="$image_name-nofat.img"
        else
            sdcard="$image_name.img"
        fi

        # remove old image files
        rm ${sdcard} > /dev/null 2>&1
        rm ${sdcard}.md5sum > /dev/null 2>&1
        rm ${sdcard}.xz > /dev/null 2>&1
        rm ${sdcard}.xz.md5sum > /dev/null 2>&1
        # ========================================
        _directsd="no"
        _ddparm="conv=notrunc"
        odir="_linux_img_mnt"
        bootdir="_boot_img_mnt"
    fi
else
    # === IN LOCAL DIRECTORY ===
    sdcard=""
    odir="linux-$distro"
    bootdir="boot-$distro"
    vfatuuid="6E35-5356"
    ext4uuid="e139ce78-9841-40fe-8823-96a304a09859"
    # ==========================
fi

if [ ! "${sdcard}" = "" ]; then

    if [ ! "${_directsd}" = "yes" ] ; then
    echo "Using disk image \"$sdcard\""
    fi
    if [ ! -f orange/boot0_OPI.fex ]; then
    echo "Error: orange/boot0_OPI.fex not found."
    exit 1
    fi

    if [ ! -f orange/u-boot_OPI.fex ]; then
    echo "Error: orange/u-boot_OPI.fex not found."
    exit 1
    fi

    if [ $linuxsize -eq 0 ]; then
    linuxsize=1024
    fi

    if [ "${_directsd}" = "yes" ] ; then
        _ersz=10
    echo "Creating bootable SD card $sdcard, please wait ..."
    echo ""
    dd if=/dev/zero of=${sdcard} bs=1M count=$_ersz > /dev/null 2>&1
    else
    echo "Creating partition images, please wait ..."
    if [ "${_boot_on_ext4}" = "yes" ] ; then
        dd if=/dev/zero of=${sdcard}1 bs=1M count=$linuxsize > /dev/null 2>&1
        _ersz=$(expr $linuxsize + 30)
    else
        dd if=/dev/zero of=${sdcard}1 bs=1M count=$fatsize > /dev/null 2>&1
        dd if=/dev/zero of=${sdcard}2 bs=1M count=$linuxsize > /dev/null 2>&1
        _ersz=$(expr $fatsize + $linuxsize + 30)
        dd if=/dev/zero of=${sdcard} bs=1M count=$_ersz > /dev/null 2>&1
    fi
    fi

    sync
    sleep 2

    # Create msdos partition table
    echo ""
    echo "Creating new filesystem on $sdcard..."
    echo -e "o\nw" | fdisk ${sdcard} > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "ERROR."
        exit 0
    fi
    sync
    echo "  New filesystem created on $sdcard."
    sleep 1
    partprobe -s ${sdcard} > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "ERROR."
        exit 1
    fi
    sleep 1

    echo ""
    echo "Partitioning $sdcard..."

    if [ "${_boot_on_ext4}" = "yes" ] ; then
        echo "  Creating linux partition"
        sext4=40960
        if [ $linuxsize == 0 ]; then
            eext4=""
        else
            eext4=$(expr $linuxsize \* 1024 \* 1024 / 512 + $sext4)
        fi
        echo -e "n\np\n1\n$sext4\n$eext4\nt\n83\nw" | fdisk ${sdcard} > /dev/null 2>&1
        sync
        sleep 2
        if [ "${_directsd}" = "yes" ]; then
            partprobe -s ${sdcard} > /dev/null 2>&1
            if [ $? -ne 0 ]; then
                echo "ERROR."
                exit 0
            fi
        fi
        linuxsize=$(expr $eext4 \* 512 / 1024 / 1024)
    else
        sfat=40960
        efat=$(expr $fatsize \* 1024 \* 1024 / 512 + $sfat - 1)
        echo "  Creating boot & linux partitions"
        sext4=$(expr $efat + 1)
        if [ $linuxsize == 0 ]; then
            eext4=""
        else
            eext4=$(expr $linuxsize \* 1024 \* 1024 / 512 + $sext4)
        fi
        echo -e "n\np\n1\n$sfat\n$efat\nn\np\n2\n$sext4\n$eext4\nt\n1\nb\nt\n2\n83\nw" | fdisk ${sdcard} > /dev/null 2>&1
        sync
        sleep 2
        if [ "${_directsd}" = "yes" ]; then
            partprobe -s ${sdcard} > /dev/null 2>&1
            if [ $? -ne 0 ]; then
                echo "ERROR."
                exit 0
            fi
        fi
        linuxsize=$(expr $eext4 \* 512 / 1024 / 1024)
    fi
    echo "  OK."
    sync
    sleep 2
    #echo -e "p\nq\n" | fdisk ${sdcard}

    echo ""
    if [ ! "${_boot_on_ext4}" = "yes" ] ; then
        echo "Formating fat partition ..."
        mkfs -t vfat -F 32 -n BOOT ${sdcard}1 > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "ERROR formating fat partition."
            exit 0
        fi
        vfatuuid=`blkid -s UUID -o value ${sdcard}1`
        echo "  fat partition formated."
        if [ "${_format}" = "btrfs" ] ; then
            echo "Formating linux partition (btrfs), please wait ..."
            # format as btrfs
            mkfs.btrfs -O ^extref,^skinny-metadata -f -L linux ${sdcard}2 > /dev/null 2>&1
            if [ $? -ne 0 ]; then
                echo "ERROR formating btrfs partition."
                exit 1
            fi
        else
            echo "Formating linux partition (ext4), please wait ..."
            mkfs -F -t ext4 -L linux ${sdcard}2 > /dev/null 2>&1
            if [ $? -ne 0 ]; then
                echo "ERROR formating ext4 partition."
                exit 1
            fi
        fi
        ext4uuid=`blkid -s UUID -o value ${sdcard}2`
    else
        if [ "${_format}" = "btrfs" ] ; then
            echo "Formating linux partition (btrfs), please wait ..."
            # format as btrfs
            mkfs.btrfs -O ^extref,^skinny-metadata -f -L linux ${sdcard}2 > /dev/null 2>&1
            if [ $? -ne 0 ]; then
                echo "ERROR formating btrfs partition."
                exit 1
            fi
        else
            echo "Formating linux partition (ext4), please wait ..."
            mkfs -F -t ext4 -L linux ${sdcard}1 > /dev/null 2>&1
            if [ $? -ne 0 ]; then
                echo "ERROR formating ext4 partition."
                exit 0
            fi
        fi
        ext4uuid=`blkid -s UUID -o value ${sdcard}1`
    fi
    echo "  linux partition formated."

    #************************************************************************
    echo ""
    echo "Instaling u-boot to $sdcard ..."
    dd if=orange/boot0_OPI.fex of=${sdcard} bs=1k seek=8 ${_ddparm} > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "ERROR installing boot0."
        exit 1
    fi
    dd if=orange/u-boot_OPI.fex of=${sdcard} bs=1k seek=16400 ${_ddparm} > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "ERROR installing u-boot."
        exit 1
    fi
    sync
    #************************************************************************

    if [ ! "${_directsd}" = "yes" ] ; then
        dd if=${sdcard} of=${sdcard}u bs=512 count=40960 > /dev/null 2>&1
        rm ${sdcard}
    fi
    echo "U-boot installed to $sdcard."
else
    echo "Creating root filesistem in local directory $odir..."
fi
# ======================================================================
