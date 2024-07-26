# OMVBackup

## Purpose
Make it easy to back up and restore a bootable drive with Linux and Open Media Vault (OMV) installed.

## Behaviour
The backup process:
- creates an image file which may be flashed to another USB drive using a flashing tool such as Raspberry Pi Imager
- optionally compresses the image file to save space
- provides uninterrupted direct, SSH, and OMV managed file accesses through out the backup and compress processes
- takes the OMV web interface offline only for the time needed to do the backup
- optionally deletes the uncompressed backup image file after the compressed backup image file has been created
- rebooting is not required 

## Testing results
Tested was done on a Raspberry Pi 5, running Armbian 6.6.41-current-bcm2712 and OMV 7.4.3-1 (Sandworm), from a 32 GB USB thumb drive.  The backup image was written to an OMV managed SSD drive.  

Run times:
- approximately 16 minutes to create the backup file (uncompressed)
- approximately another 36 minutes to compress the backup file

CPU usage:
- the backup process used only marginally more CPU than when the system was idle
- the compression process used significantly more CPU, with the OVM dashboard reporting over 70% busy much of the time. Regardless, the OMV Web Interface and OMV managed file access performance remained respectable during the compress process.

File sizes:
- uncompressed backup file: 28.6 GB
- compressed backup file:    776 MB ( < 3% of the uncompressed backup file size )

Flashing from the backup:
- using Raspberry Pi Imager it took about an hour to flash from the backed-up image. This timing was not impacted by the backed-up image file was compressed or not.

## Prerequisites:
	
1.  OMV should be installed and configured, this to include at least one OMV drive to which the backup may be saved

2.  Either direct or remote (SSH) access is required to the system running OMV

## Setup:

Setup should take about five minutes.  Here are the steps:

1.  Create a directory on one of the OMV managed drives as a target for the backup

2.  Sign onto the OMV machine's command line. If you sign in as root then prefixing the commands below with 'sudo' is not required.

3.  If you don't already have 7zip installed, then it will need to be installed:

		sudo apt install p7zip-full

4.  If you don't already have wget installed, then it will need to be installed:

		sudo apt-get install wget

5.  Create a directory in which the shell file will be stored for example:

		mkdir backupRoutine

6.  Add the backup shell found in this repository into the directory created in the step above

		cd backupRoutines
  
		wget -O createBackup.sh https://raw.githubusercontent.com/roblatour/OMVBackup/master/createBackup.sh

7.  Edit the file createBackup.sh

    as outlined in the comments:  

	 change the values for:

	  BACKUP_DRIVE_ID

	  BACKUP_DRIVE_NAME

	  BACKUP_DIRECTORY

	
	 optionally change the values for:

	  BACKUP_FILENAME

	  COMPRESS_IMAGE

	  COMPRESSION_LEVEL

	  REMOVE_UNCOMPRESSED_IMAGE_WHEN_COMPRESSED_IMAGE_HAS_BEEN_CREATED

    
    note: the file createBackup.sh may be edited with the following command:

		sudo nano createBackup.sh

	  and when done press:

	   Ctrl-X

	   Y

	   Enter
	   
8. Set the system permissions to allow the shell file to be executed

		sudo +x createBackup.sh

9. Depending on the capacity of the drive to be imaged (and optionally compressed) the overall process may take a good amount of time to complete.

    For more information, please see the 'Testing Results' above.

	Accordingly, if you don't sign as the root user you will need to extend the (default 15 minute) sudo timeout limit to be long enough for the shell to run to completion.

	To do this, issue the command:
	
		sudo visudo -f /etc/sudoers.d/timeout

	in the file that opens, add / modify a line to read:

		Defaults timestamp_timeout=120

	and when done press:

	  Ctrl-X

	  Y

	  Enter
	   
    Notes:

	 the '120' above refers to 120 minutes, as needed this value may changed

	 this new timing will apply immediately and whenever the machine is accessed in the future
	  


## Manually running the backup

There are two ways to manually run the backup:

1. via the command terminal

   1.1 Either directly or remotely access the OMV machine's command line

   1.2 Change the current directory the directory in which the shell file is stored, for example:
   
		cd ~/backupRoutine

   1.3 Run the createBackup shell:
   
		./createBackup.sh
  
       (enter your password if prompted)

2. via the OMV Web Interface
   This requires that a scheduling task has been setup in OMV as noted below and that you manually run it (also as described below).
   
Note: if within OMV, System - Notification - Events Process Monitoring is enabled then a few e-mail alerts will be generated while the backup is running.   

## Automatically running the backup
OMV's scheduling feature can be used to setup automatic periodic backups

To do this:
1.  Sign on to the OMV Web interface as admin
2.  Go to System - Scheduled Tasks and click on the + sign in the horizontal menu bar to add a new task
3.  Check Enabled
4.  Set your desired scheduling;
    For example mine runs on the first day of each month at 1am
	with Certain Day; Minute 0; Hour 1; Day of Month 1; Month \*; Day of week \*
5.  Set the user to root
6.  Set the command to:

    (from the root user's perspective the path on your system where the createBackup.sh file is stored)\createBackup.sh

	for example mine is set to:

	/home/rob/backupRoutine/createBackup.sh

7. The option 'Send command output via email' may be checked if within the OMV Web Interface System - Notifications - Settings is enabled	
8. Save and apply pending changes

You can test this by clicking on the task and then clicking on the right arrow run icon in the horizontal menu bar.
However, if you do this your OMV Web connection should almost immediately be disconnected as the first thing the shell does, prior to making backup, is (as mentioned above) take the OMV web interface offline and put the OS drive in read only mode for the time needed to do the backup.
Having that said, while the backup is running you will still have direct, SSH and OMV managed file accesses (also as mentioned above).

## When the backup is finished
If you need to restore your OS + OMV drive then having easy access to the either the backup image file or the compressed backup image file will be important.
Accordingly, it is best to copy at least one of these files to an easy to access location not managed by OMV.
Optionally, you can flash it to a suitable backup drive (more information directly below)

## Restoring from the backup
Use a tool such as Raspberry Pi Imager to flash the image to another drive of the same capacity or greater.
Of note, with Raspberry Pi Imager the compressed image file may be used without uncompromising it

If you use Raspberry Pi Imager

Click on 'Operating System' - 'Use Custom' - and select your compressed (or uncompressed) backup file

Click on 'Choose Storage' - select your USB to be flashed

Click Next

Click 'No' to 'Would you like to apply OS customization settings'

Be completely sure you have selected the correct drive, and click 'Yes' to the overwrite warning prompt only if your are completely sure you have selected the correct drive

Its a good idea to test restoring the backup to a second drive and then check that second drive works fine in your OMV machine.

Hope this will be of help to you!

## Support

[<img alt="buy me  a coffee" width="200px" src="https://cdn.buymeacoffee.com/buttons/v2/default-blue.png" />](https://www.buymeacoffee.com/roblatour)

copyright Rob Latour, 2024

