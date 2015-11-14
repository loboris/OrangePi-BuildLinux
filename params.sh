
# =====================================================
# ==== P A R A M E T E R S ============================
# =====================================================


# *****************************************************
# Set to "yes" to create realy minimal image          *
# *****************************************************
ONLY_BASE="no"


# *****************************************************
# Set hostname, user to be created                    *
# and root and user passwords                         *
# *****************************************************
HOSTNAME="OrangePI"
USER="orangepi"
ROOTPASS="orangepi"
USERPASS="orangepi"


# *****************************************************
# Set timezone, for default (HOST'S) set _timezone="" *
# *****************************************************
_timezone="Etc/UTC"
#_timezone=""


# *****************************************************
# SET IF YOU WANT TO INSTALL SPECIFIC LANGUAGE,       *
# COMMENT FOR DEFAULT (HOST) settings                 *
# *****************************************************
LANGUAGE="en"
LANG="en_US.UTF-8"


# *****************************************************
# Set the base name of your image.                    *
# Distro name is automaticaty appended, and the image *
# will be "image_name-distro.img"                     *
# --------------------------------------------------- *
# IF image_name="", image file won't be created,      *
# instalation will be created in local directories    *
# linux-$distro & boot-$distro                        *
# YOU CAN CREATE THE IMAGE LATER RUNNING:             *
# sudo ./image_from_dir <directory> <DEVICE|IMAGE>    *
# === IT IS THE RECOMMENDED WAY OF IMAGE CREATION === *
# --------------------------------------------------- *
# IF image_name is BLOCK DEVICE (/dev/sdXn)           *
# LINUX filesystem will be created directly on it     *
# Partition must exist !                              *
# IF _format="" partition will NOT be formated        *
# otherwyse it will be formated with specified format *
# *****************************************************
image_name=""
#image_name="minimal"
#image_name="/dev/sdg"


# *****************************************************
# Filesystem type for linux partition                 *
# If btrfs is selectet, partition will be mounted     *
# "compressed" option, you can save some sdcard space *
# --------------------------------------------------- *
# Used when creating the system directly on SDCard or *
# SDCard image file and in "image_from_dir" script    *
# *****************************************************
_format="ext4"
#_format="btrfs"


# *****************************************************
# SD Card partitions sizes in MB (1024 * 1024 bytes)  *
# --------------------------------------------------- *
# If creating on physical sdcard (not image) you can  *
# set "linuxsize=0" to use maximum sdcard size        *
# --------------------------------------------------- *
# When creating the image with "image_from_dir" script*
# "linuxsize" is calculated from directory size       *
# *****************************************************
fatsize=64
linuxsize=800


# *****************************************************
#   Select ubuntu/debian distribution and repository  *
#     === SELECT ONLY ONE distro AND ONE repo ===     *
# *****************************************************

# === Ubuntu ===
#distro="precise"
distro="trusty"
#distro="utopic"
#distro="vivid"
#distro="wily"
repo="http://ports.ubuntu.com/ubuntu-ports"

# === Debian ===
#distro="wheezy"
#distro="jessie"
#repo="http://ftp.hr.debian.org/debian"
#raspbian="no"

# === Raspbian ===
#distro="wheezy"
#distro="jessie"
#repo="http://archive.raspbian.org/raspbian"
#raspbian="yes"

# ******************************************************
# If creating the image, you can xz compress the image *
# after creation and make the md5sum file              *
# to do that automatically, set  _compress="yes"       *
# ******************************************************
_compress="yes"


# =====================================================
# IF YOU WANT TO HAVE BOOT FILES ON EXT4 PARTITION    =
# AND NOT ON SEPARATE FAT16 PARTITION                 =
# set  _boot_on_ext4="yes"  and                       =
# FAT partitin won't be created                       =
# --------------------------------------------------- =
# DO NOT CHANGE FOR NOW !                             =
# =====================================================
_boot_on_ext4="no"


# ^^^^ P A R A M E T E R S ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
