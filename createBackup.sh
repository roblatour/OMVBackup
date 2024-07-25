#!/bin/bash
# Copyright Rob Latour, 2024
# License MIT

# BACKUP_DRIVE_ID:
#  Use the command:
#    df -h
#  to find the BACKUP_DRIVE_ID where the backup will be stored.
BACKUP_DRIVE_ID="/srv/dev-disk-by-uuid-fd45dad9-11a5-48a6-aad7-a71405408632"

# BACKUP_DRIVE_NAME
#  Use the following two commands to find the BACKUP_DRIVE_NAME:
#   cd BACKUP_DRIVE_ID  # for example: cd /srv/dev-disk-by-uuid-fd45dad9-11a5-48a6-aad7-a71405408632
#   ls
BACKUP_DRIVE_NAME="BasementSSD"

# BACKUP_DIRECTORY
#  Use the name of the directory created on the BACKUP_DRIVE_ID + BACKUP_DRIVE_NAME for storing the backup image file / compressed backup image file.
BACKUP_DIRECTORY="OMV Backup"

# BACKUP_FILENAME
# do not include the file extension in the filename below.
BACKUP_FILENAME="OpenMediaVaultBackup"

# COMPRESS_IMAGE
#  set to true to create a compressed image file, set to false not to create a compressed image file.
COMPRESS_IMAGE=true

# COMPRESSION_LEVEL
# Set the COMPRESSION_LEVEL level (0 no COMPRESSION_LEVEL but fast, 9 best COMPRESSION_LEVEL but slower).
COMPRESSION_LEVEL=9

#REMOVE_UNCOMPRESSED_IMAGE_WHEN_COMPRESSED_IMAGE_HAS_BEEN_CREATED
# Set to true to remove the uncompressed image file after the compressed image file has been create, set to false to keep the uncompressed image file.
REMOVE_UNCOMPRESSED_IMAGE_WHEN_COMPRESSED_IMAGE_HAS_BEEN_CREATED=false

#DATE_TIME
# Get the current date and time (please do not change).
DATE_TIME=$(date +"_%Y-%m-%d_%H-%M-%S")

# OS_DRIVE
# Get the device that holds the root filesystem (please do not change).
OS_DRIVE=/dev/$(lsblk -no pkname $(mount | grep "on / " | cut -d' ' -f1))


# OK lets go!

if [ ! -d "${BACKUP_DRIVE_ID}/${BACKUP_DRIVE_NAME}/${BACKUP_DIRECTORY}" ]; then
  echo "Backup directory '${BACKUP_DRIVE_ID}/${BACKUP_DRIVE_NAME}/${BACKUP_DIRECTORY}' does not exist!"
  echo "Backup not run"
  exit 1
fi

# using sudo before date in the line below forces the user to enter their password (if required) prior to the balance of the shell being executed
sudo date


if sudo -n true 2>/dev/null; then
  echo "Backup routine begun."
else
  echo "User does not have sudo permissions!"
  echo "Backup not run."
  exit 2
fi

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

# Create the image file
sudo dd bs=4M if=${OS_DRIVE} of="${BACKUP_DRIVE_ID}/${BACKUP_DRIVE_NAME}/${BACKUP_DIRECTORY}/${BACKUP_FILENAME}${DATE_TIME}.img" status=progress oflag=sync

echo "... backup file created."

echo "Restoring the OS drive to read/write mode."

# Set disk to read-write
sudo blockdev --setrw /dev/sda

echo "Restoring online access to Open Media Vault ..."

# Start services
sudo systemctl unmask nginx.service > /dev/null
sudo systemctl start nginx.service > /dev/null
sudo systemctl unmask openmediavault-engined.service > /dev/null
sudo systemctl start openmediavault-engined.service > /dev/null

echo "Open Media Vault is back online after: $((($(date +%s) - $(date +%s --date="$(ps -o lstart= -p $$)")) / 60)) minutes and $((($(date +%s) - $(date +%s --date="$(ps -o lstart= -p $$)")) % 60)) seconds."

if $COMPRESS_IMAGE; then

   echo "Compressing the image file ..."

   cd "${BACKUP_DRIVE_ID}/${BACKUP_DRIVE_NAME}/${BACKUP_DIRECTORY}"
   7z a "${BACKUP_DRIVE_ID}/${BACKUP_DRIVE_NAME}/${BACKUP_DIRECTORY}/${BACKUP_FILENAME}${DATE_TIME}.xz" "${BACKUP_DRIVE_ID}/${BACKUP_DRIVE_NAME}/${BACKUP_DIRECTORY}/${BACKUP_FILENAME}${DATE_TIME}.img" -mx${COMPRESSION_LEVEL} -txz -bsp2

   echo "... image file compressed."

   if $REMOVE_UNCOMPRESSED_IMAGE_WHEN_COMPRESSED_IMAGE_HAS_BEEN_CREATED; then

    rm "${BACKUP_DRIVE_ID}/${BACKUP_DRIVE_NAME}/${BACKUP_DIRECTORY}/${BACKUP_FILENAME}${DATE_TIME}.img"
    echo "uncompressed image file removed."

   fi

fi

# Display the total execution time
echo "Total execution time: $((($(date +%s) - $(date +%s --date="$(ps -o lstart= -p $$)")) / 60)) minutes and $((($(date +%s) - $(date +%s --date="$(ps -o lstart= -p $$)")) % 60)) seconds."
echo "Backup routine complete."

exit 0