# Draft WIP

# OMVBackup
a set of Linux shells to backup an OS drive with Open Media Vault (OMV) installed on it

# License
MIT

# Purpose
I use these shells to backup my USB thumb drive with an Operating System (Armbian) and OMV installed and configured on it.
They were created with a goal of making the OMV + OS backup and restore process as simple as possible.
After reviewing the terms of the MIT license, you are welcome to give them.

# Included in this repository:
  1. this readme file
  2. createBackupWorker.sh (a shell to do the actual backup)
  3. createBackup.sh (a shell to call createBackupWorker.sh using a sudo command - which allows the user to enter their password to run sudo commands up front, rather than later in the backup process)  

# Behavior
The backup process: 
- creates a compressed .img file which may be flashed to another like (or larger) USB using a flashing tool such as Raspberry Pi Imager
- allows uninterrupted ongoing access to OMV drives
- puts the OS drive in read only mode for the time needed to do the actual backup
- takes the OMV web interface offline only for the time needed to do the actual backup
- continues to run in the background to compress the backup image file to a zip file
- optionally deletes the uncompressed backup image file after the compressed backup image file has been created

# Testing
These shells have been tested on my Raspberry Pi 5, running Armbian and OMV off of a USB thumb drive
Backup directory is on an SSD drive

Run times on my system:
- approximately 16 minutes to create the uncompressed backup
- approximately another 15 minutes to compress the uncompressed backup
  
CPU usage:
- when backup is not running the Raspberry Pi's 4 CPUs were normally between 0 and 15%, but at most times closer to 0%
- when backup is running Raspberry Pi's 4 CPUs were normally between 0 and 15%, but at most times closer to 0% however somewhat higher than when the backup was not running
- when the uncompressed backup file is being compressed three of the Raspberry Pi's CPU were the same as above, but one CPU was at 100%  

# Pre-requests:
1. OMV should be installed and configured on your machine, this to include at least one OMV drive to which the backup may be saved

2. You will need remote (SSH) access to your system running OMV (this not through the OMV web interface)
  
3. create a directory on one of the attached OMV drives as a target for the backup

4. you will need the zip program installed (see setup below) 

# Setup

1. SSH into the OMV machine

2. if you don't already have zip installed, then it will need to be installed:
   sudo apt update
   sudo apt install zip
   
3. create a directory in which the shell files will be stored for example:
   mkdir backupRoutine

4. put the two shells found in this repository into that directory
   cd backupRoutines
   xxx
      
5. edit the file createBackupWorker.sh

   change the BACKUP_DIRECTORY path as outlined in the comments
     
   optionally, if you want the .img file to be removed after the zipped image file is created then uncomment the line:
   # rm ${BACKUP_DIRECTORY}${BASE_BACKUP_FILENAME}${DATE_TIME}.img
   by removing the '#'

   note: the file may be edited with the following command:
     sudo nano createBackupWorker.sh
     and press Ctrl-X  when done
   
7. set your system permissions to allow the scripts to be executed
   
   sudo +x createBackup.sh
   sudo +x createBackupWorker.sh
   
# Running the backup

1. make your current directory the directory in which the shell files are stored and run the createBackup shell, for example:
   cd backupRoutine
   ./createBackup.sh
   (enter your password if prompted)

   example run:
   
# When the backup is finished

If OMV goes down and you need to restore your OS + OMV drive then you will need easy access to the compressed backup file.
Accordingly, it is best to copy the compressed backup file to another easy to access location not on your OMV drives.

# Retoring the backup

Use a tool such as Raspberry Pi Imager to flash the image to another drive
Of note, with Raspberry Pi Imager the compressed image file does not need to be uncompressed first
Raspberry Pi Imagerer - 

   




