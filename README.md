# sw-osbox-base

this is a OSBox dietpi image configuration for osbox.

These file are for use with a DietPi image ( dietpi.com)

This prepared image will run the osbox binaries (https://github.com/jerryhopper/sw-osbox-bin)

## instructions: 

Download DietPi image and mount it.
 
copy  /boot  and /etc to the root of the image.

unmount the image, and flash the image to a sd-card.

The insert the sd-card in your sbc, which will start the installation.

Once installed ( this could take a while ) ,  goto http://osbox.local 

### Example 
Example bashscript code on how to use this 

<pre>
#!/bin/bash

FILE=/path/to/dietpi/.img
MOUNTPATH=/some/folder/used/for/mounting
GITPATH=/path/to/this/repo

# find bootstart-offset
BOOTSTARTSTR=$(sudo fdisk  -l $FILE|grep ".img1"|cut -d' ' -f 8)
FILESYSTEMSTR=$(sudo fdisk -l $FILE|grep ".img1"|cut -d' ' -f 14)
SECSTARTSTR=$(sudo fdisk -l $FILE|grep -m 2 "Sector size"|cut -d' ' -f 4)
BOOTSTART=$((BOOTSTARTSTR * SECSTARTSTR))

# mount the image
sudo mount -o loop,rw,sync,offset=$BOOTSTART $FILE $MOUNTPATH

# Copy files to mounted image..."
cp -v -r $GITPATH/etc $MOUNTPATH
cp -v -r $GITPATH/boot $MOUNTPATH

# Unmounting the image

sudo umount $MOUNTPATH
echo "dietpi image '$FILE' was patched."

</pre>

# tested with the following hardware.

NanoPi ZeroPi Allwinner H3 Cortex-A7 1.2GHz quad core 512MB DDR3
https://dietpi.com/downloads/images/DietPi_NanoPiZeroPi-ARMv7-Buster.7z

NanoPi NEO2 Black Allwinner H5 1.2 GHz quad core (ARMv8) 1024MB DDR3
https://dietpi.com/downloads/testing/DietPi_NanoPiNEO2Black-ARMv8-Buster.7z
