# sw-osbox-base

OSBox dietpi image configuration for osbox.

These file are for use with a DietPi image ( dietpi.com)

## instructions: 

Download DietPi image and mount it.
 
copy  /boot  and /etc to the root of the image.

unmount the image, and flash the image to a sd-card.

The insert the sd-card in your sbc, which will start the installation.



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

