#!/bin/bash
# Copyright Rob Latour, 2024
# License MIT

# Set the backup output directory path name as a variable.  
#   To do this:
#
#   For the initial part of the directory path name the code below uses 
#   '/srv/dev-disk-by-uuid-fd45dad9-11a5-48a6-aad7-a71405408632'
#   your system will have a different initial part.
#   Use the command 'df -h' to find the initial part of the path name on your system;
#   'df -h' will list all your Open Media Vault (OMV) drives, find the one you want to use.
#
#   Next use the OMV drive name as the second part of the path name;
#   the code below uses: '/BasementSSD' as the second part of the path name, yours will be different
#   if you don't know the Open Media Vault drive name use the following two commands to find it:
#      'cd FirstPartOfThePathName'; for example 'cd /srv/dev-disk-by-uuid-fd45dad9-11a5-48a6-aad7-a71405408632'
#      'ls'
#   Finally, use a directory you have created on the OMV drive as final part of the path name;
#   the code below uses: '/OMVBackup/' as the final part of the path name
#
#   update the value after the '=' sign below:
BACKUP_DIRECTORY=/srv/dev-disk-by-uuid-fd45dad9-11a5-48a6-aad7-a71405408632/BasementSSD/OMVBackup/

# Set the backup output filename as a variable (you don't need to change this, but you can if you like):
BASE_BACKUP_FILENAME=OpenMediaVaultBackup

# Set the compression level (0 no compression but fast, 9 best compression but slower) (you don't need to change this, but you can if you like): 
COMPRESSION=9

# Get the current date and time (you don't need to change this, but you can if you like):
DATE_TIME=$(date +"_%Y-%m-%d_%H-%M-%S")

# Get the device that holds the root filesystem (do NOT change this)
OS_DRIVE=/dev/$(lsblk -no pkname $(mount | grep "on / " | cut -d' ' -f1))

# OK lets go!

# Opening display
echo "Backup routine begun"

echo "Taking down online access to Open Media Vault ..."

# Stop services
sudo systemctl stop nginx.service > /dev/null 
sudo systemctl mask nginx.service > /dev/null 
sudo systemctl stop openmediavault-engined.service > /dev/null 
sudo systemctl mask openmediavault-engined.service > /dev/null 

echo "Placing the OS drive in read only mode ..."

# Set disk to read-only
sudo blockdev --setro /dev/sda

echo "Creating backup file ..."

# Create the ISO file
sudo dd bs=4M if=${OS_DRIVE} of=${BACKUP_DIRECTORY}${BASE_BACKUP_FILENAME}${DATE_TIME}.img status=progress oflag=sync

echo "... backup file created"

echo "Restoring the OS drive to read/write mode"

# Set disk to read-write
sudo blockdev --setrw /dev/sda

echo "Restoring online access to Open Media Vault ..."

# Start services
sudo systemctl unmask nginx.service > /dev/null 
sudo systemctl start nginx.service > /dev/null 
sudo systemctl unmask openmediavault-engined.service > /dev/null 
sudo systemctl start openmediavault-engined.service > /dev/null 

echo "Open Media Vault is back online after: $((($(date +%s) - $(date +%s --date="$(ps -o lstart= -p $$)")) / 60)) minutes and $((($(date +%s) - $(date +%s --date="$(ps -o lstart= -p $$)")) % 60)) seconds"

echo "Compressing the backup file ..."

# Compress the image file
cd  ${BACKUP_DIRECTORY}
7z a ${BACKUP_DIRECTORY}${BASE_BACKUP_FILENAME}${DATE_TIME}.xz ${BACKUP_DIRECTORY}${BASE_BACKUP_FILENAME}${DATE_TIME}.img -mx${COMPRESSION} -txz -bsp2

echo "... backup file now compressed"

# Optional: remove the original ISO file - remove the # at begining of the next line if you want to delete the uncompressed image file after the compressed image file has been created
# rm ${BACKUP_DIRECTORY}${BASE_BACKUP_FILENAME}${DATE_TIME}.img

# Display the total execution time
echo "Total execution time: $((($(date +%s) - $(date +%s --date="$(ps -o lstart= -p $$)")) / 60)) minutes and $((($(date +%s) - $(date +%s --date="$(ps -o lstart= -p $$)")) % 60)) seconds"
echo "Backup routine complete"