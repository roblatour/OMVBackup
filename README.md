# Draft WIP

# OMVBackup
Linux shell to backup Open Media Vault (OMV)

# License
MIT

# Purpose

I use these shells to backup my USB thumb drive with an Operating System (Armbian) and OMV installed and configured on it.
They were created with a goal of making the OMV + OS backup and restore process as simple as possible.
You are welcome to give them a try.

# Included in this respository:
  1. createBackupWorker.sh (a shell to do the actual backup)
  2. createBackup.sh (a shell to call createBackupWorker.sh using a sudo command - which allows the user to enter their password to run sudo commands up front, rather than later in the backup process)  

# Notes
The backup process: 
- creates a compressed .img file which may be flashed to another like (or larger) USB using a flashing tool such as Rasperry Pi Imager
- takes the Open Media Vault web interface off line for the time needed to do the actual backup (about 6 minutes on my system - a Raspberry Pi running Armbian)
- continues to run in the background to compress the backup to a zip file
- optionally deletes the backup image file after the zip file has been created

# Pre-requests (assuming OMV is already installed and setup on your machine):

1. OMV should be installed and configured on your machine, this to include at least one OMV drive to which the backup may be saved
  
2. create a directory on one of the attached OMV drives as a target for the backup
  (once the backup has been created, the backup file can be

3. if you don't already have zip installed, then it will need to be installed:
   sudo apt update
   sudo apt install zip

# Setup

1. edit the file createBackupWorker.sh

   change the BACKUP_DIRECTORY path as outlined in the comments
     
   optionally, if you want the .img file to be removed after the zipped image file is created then uncomment the line:
   # rm ${BACKUP_DIRECTORY}${BASE_BACKUP_FILENAME}${DATE_TIME}.img
   by removeing the '#'

   note: the file can be edited with the following command:
     sudo nano createBackupWorker.sh
     and press Ctrl-X  when done

2. set your system permissions to allow the scripts to be executed
   
   to do this, make your current directory the directory in which the shell files are stored, for example
      cd backupRoutine
   and issue the commands:
      sudo +x createBackup.sh
       sudo +x createBackupWorker.sh
   
# Running the backup

1. make your current directory the directory in which the shell files are stored and run the createBackup shell, for example:
   cd backupRoutine
   ./createBackup.sh

# Copy the backup to another easy to access location not on your OMV drives
  If OMV goes down and you need to restore your OS + OMV drive then you will need easy access to the compressed backup file
   




