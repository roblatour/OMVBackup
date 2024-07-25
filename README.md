# OMVBackup

copyright Rob Latour, 2024

## Project outline
A pair of Linux shells to backup an OS drive with Open Media Vault (OMV) installed on it

## License
MIT

## Purpose
I use these shells to backup my USB thumb drive with an Operating System (Armbian) and OMV installed and configured on it.
They were created with a goal of making the OS + OMV backup and restore process as simple as possible.
After reviewing the terms of the MIT license, you are welcome to use them.

## Included in this repository:
  1. this README file
  2. LICENSE file
  2. createBackupWorker.sh (a shell to do the actual backup)
  3. createBackup.sh (a shell to call createBackupWorker.sh using a sudo command - which allows the user to enter their password to run sudo commands up front, rather than later in the backup process)  

## Behaviour
The backup process: 
- creates a compressed image file which may be flashed to another like (or larger) USB drive using a flashing tool such as Raspberry Pi Imager
- allows uninterrupted access to OMV drives through out the backup and backup file compress process
- takes the OMV web interface offline and puts the OS drive in read only mode only for the time needed to do the actual backup
- continues to run in the background to compress the uncompressed backup image file without the need to have the OMV web interface offline or the OS drive in read only mode
- optionally deletes the uncompressed backup image file after the compressed backup image file has been created

## Testing results
I've tested these shells on a Raspberry Pi 5, running Armbian 6.6.41-current-bcm2712 and OMV 7.4.3-1 (Sandworm), from a 32 GB USB thumb drive
Backup directory is on an SSD drive

Run times on my system:
- approximately 16 minutes to create the backup file (uncompressed)
- approximately another 35 minutes to compress the backup file

CPU usage:
- the backup process used only marginally more CPU than when the system was idle
- the compression process used significantly more CPU, with the OVM dashboard reporting over 70% busy much of the time, regardless OMV and file access performance remained respectable 

File sizes:
- uncompressed backup file: 28.6 GB
- compressed backup file:    776 MB (>3% of the uncompressed backup file size)

## Prerequisites:
1. OMV should be installed and configured on your machine, this to include at least one OMV drive to which the backup may be saved

2. Remote (SSH) access is required to the system running OMV (this not through the OMV web interface)
  
3. create a directory on one of the attached OMV drives as a target for the backup

4. the 7zip program will need to be installed (see Setup point 2 below) 

## Setup
1. SSH into the OMV machine

2. if you don't already have 7zip installed, then it will need to be installed:
   sudo apt update
   sudo apt install p7zip-full
   
3. create a directory in which the shell files will be stored for example:
   mkdir backupRoutine

4. put the two shells found in this repository into that directory
   cd backupRoutines
   xxxx
      
5. edit the file createBackupWorker.sh

   change the BACKUP_DIRECTORY path as outlined in the comments
     
   optionally, if you want the .img file to be removed after the compressed image file is created then uncomment the line:
   \# rm ${BACKUP_DIRECTORY}${BASE_BACKUP_FILENAME}${DATE_TIME}.img
   by removing the \#

   note: the file may be edited with the following command:
     sudo nano createBackupWorker.sh
	 when done press:
          Ctrl-X
		  Y
		  Enter
   
6. set your system permissions to allow the scripts to be executed
   
   sudo +x createBackup.sh
   sudo +x createBackupWorker.sh
   
## Running the backup
1. make your current directory the directory in which the shell files are stored and run the createBackup shell, for example:

   cd ~/backupRoutine
   ./createBackup.sh
   
   (enter your password if prompted)
  
## When the backup is finished

If OMV goes down and you need to restore your OS + OMV drive then you will need easy access to the compressed backup file.
Accordingly, it is best to copy the compressed backup file to another easy to access location not on your OMV drives.
Optionally, you can flash it to a suitable backup drive at this time

## Retoring the backup

Use a tool such as Raspberry Pi Imager to flash the image to another drive
Of note, with Raspberry Pi Imager the compressed image file does not need to be uncompressed first

If you use Raspberry Pi Imager
    Click on 'Operating System' - 'Use Custom' - and select your compressed (or uncompressed) backup file
	Click on 'Choose Storage' - select your USB to be flashed
	Click Next
	Click 'No' to 'Would you like to apply OS customization settings'
	Be completely sure you have selected the correct drive, and click 'Yes' to the overwrite warning prompt only if your are completely sure you have

Its a good idea to test restoring the backup to a second drive and then checking that second drive works fine in your OMV machine

Hope this will be of help to you

## Support

[<img alt="buy me  a coffee" width="200px" src="https://cdn.buymeacoffee.com/buttons/v2/default-blue.png" />](https://www.buymeacoffee.com/roblatour)

