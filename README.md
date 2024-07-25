# OMVBackup

copyright Rob Latour, 2024

## Project outline
A Linux shell to backup an OS drive with Open Media Vault (OMV) installed on it

## License
MIT

## Purpose
I use this shell to backup my USB thumb drive with an Operating System (Armbian) and OMV installed and configured on it.
It was created with a goal of making the OS + OMV backup and restore process as simple as possible.
After reviewing the terms of the MIT license, you are welcome to use it too.

## Included in this repository:
  1. this README file
  2. LICENSE file
  3. createBackup.sh (the shell to do the backup)
  
## Behaviour
The backup process: 
- creates a image file which may be flashed to another like (or larger) USB drive using a flashing tool such as Raspberry Pi Imager
- optionally compresses the image file to save space
- allows uninterrupted access to OMV drives through out the backup and compress processes
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

## Prerequisites and setup:
1.  OMV should be installed and configured on your machine, this to include at least one OMV drive to which the backup may be saved

2.  create a directory on one of the attached OMV drives as a target for the backup
    
3.  Remote (SSH) access is required to the system running OMV (this not through the OMV web interface)
    
4.  SSH into the OMV machine (if you ssh in as root prefixing the commands below with sudo is not required)
    
5.  if you don't already have 7zip installed, then it will need to be installed:
    sudo apt update
    sudo apt install p7zip-full
    
6.  if you don't already have wget installed, then it will need to be installed:
    sudo apt update
    sudo apt-get install wget
    
7.  create a directory in which the shell files will be stored for example:
    mkdir backupRoutine
    
8.  put the backup shell found in this repository into that directory
    cd backupRoutines
    wget -O createBackup.sh https://raw.githubusercontent.com/roblatour/OMVBackup/master/createBackup.sh
       
9.  edit the file createBackup.sh
    
    as outlined in the comments, change the values for:
	   BACKUP_DRIVE_ID
	   BACKUP_DRIVE_NAME
	   BACKUP_DIRECTORY
	   
	as outlined in the comments, optionally change the values for:
	   BACKUP_FILENAME
	   COMPRESS_IMAGE
       REMOVE_UNCOMPRESSED_IMAGE_WHEN_COMPRESSED_IMAGE_HAS_BEEN_CREATED
       COMPRESSION_LEVEL 

    note: the file may be edited with the following command:
      sudo nano createBackup.sh
      and when done press:
           Ctrl-X
  	       Y
  	       Enter
    
10. set your system permissions to allow the shell to be executed
   
    sudo +x createBackup.sh
	
11. depending on the size of your drive to be imaged (and optionally compressed) the overall process may take a good amount of time to complete
    for more information, please see the 'Testing Results' above
	accordingly, if you don't ssh in using root, then you will need to extend the sudo timeout limit to be long enough for the shell to run to completion
	to do this, you may issue the command:
	
	sudo visudo -f /etc/sudoers.d/timeout
	
	and in the file that opens up add / modify a line to read:
	
	Defaults timestamp_timeout=120
	
	and when done press:
        Ctrl-X
  	    Y
  	    Enter	  
		
    Note: the 120 above refers to 120 minutes, if needed you can make this longer

## Running the backup
1. SSH into the OMV machine (this not through the OMV web interface)

2. make your current directory the directory in which the shell file is stored, for example 
   cd ~/backupRoutine
   
3. run the createBackup shell
   ./createBackup.sh
   (enter your password if prompted)
  
## When the backup is finished
If you need to restore your OS + OMV drive then you will need easy to the either the backup image file or the compressed backup image file.
Accordingly, it is best to copy at least one of these to an easy to access location not managed by OMV
Optionally, you can flash it to a suitable backup drive

## Retoring the backup
Use a tool such as Raspberry Pi Imager to flash the image to another drive
Of note, with Raspberry Pi Imager the compressed image file does not need to be uncompressed first

If you use Raspberry Pi Imager
    Click on 'Operating System' - 'Use Custom' - and select your compressed (or uncompressed) backup file
	Click on 'Choose Storage' - select your USB to be flashed
	Click Next
	Click 'No' to 'Would you like to apply OS customization settings'
	Be completely sure you have selected the correct drive, and click 'Yes' to the overwrite warning prompt only if your are completely sure you have selected the correct drive
	
Its a good idea to test restoring the backup to a second drive and then check that second drive works fine in your OMV machine

## Setting up a scheduled job to automatically backup your drive
In OMV there is a feature

Hope this will be of help to you

## Support

[<img alt="buy me  a coffee" width="200px" src="https://cdn.buymeacoffee.com/buttons/v2/default-blue.png" />](https://www.buymeacoffee.com/roblatour)

