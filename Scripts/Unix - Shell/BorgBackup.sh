#!/bin/bash
# Set the backup source directory
BACKUP_SRC=/path/to/backup/source

# Set the mount point for the USB drive
MOUNT_POINT=/mnt/usb

# Set the Borg backup repository directory
BORG_REPO=/path/to/borg/repository

# Set the log file path
LOG_FILE=/var/log/$(date --iso-8601)-borg-backup.log

function displayHelp() {
cat <<HelpText
Usage: $0 [OPTION]...

This script uses BorgBackup (Borg) to write to a defined USB device, while automatically mounting it and logging the backup attempt.

Co written on 2023-03-22 with ChatGPT with further modification to improve usability.

Options:
 -r, --reset : reset script
HelpText
}

if [[ $(borg -h 2>/dev/null) && $? -gt 0 ]]; then
	echo "BorgBackup (aka Borg) does not appear to be installed on $HOSTNAME. Please install and re-run this script."
	exit 2
fi

if [[ "$reset" == "true" ]]; then # Clear targetUSB, modelUSB, and vendorUSB variables
	unset targetUSB modelUSB vendorUSB
	exec "$0" "$@" # Restart script
fi

if [[ "$1" == "" ]]; then # tip if no option
	echo -e "For more options see compile.sh -h.\n"
else # parse options
	while [[ "$1" ]]; do
		case $1 in
			-r | --reset)
				reset="true"
				shift
				;;
			-h | --help)
				displayHelp
				exit 0
				;;
			*)
				echo "Unknown argument $1."
				displayHelp
				exit 1
				;;
		esac
		shift
	done
fi

echo "Source location is: $BACKUP_SRC"
echo "USB mount point is: $MOUNT_POINT"
echo "Borg backup repo is: $BORG_REPO"
echo "Log file is: $LOG_FILE"

if [ -z "$targetUSB" ]; then # Check if targetUSB variable is defined
    # List USB devices and prompt user to select one
    echo -e "\nSelect a USB device:"
    select usb in $(lsblk -dno MODEL,UUID,VENDOR,NAME,SIZE | grep -vE '^$' | awk '{print $1" "$2" "$3" "$4"}')
    do
        # Store selected USB details as variables
        modelUSB=$(echo $usb | awk '{print $1}')
        targetUSB=$(echo $usb | awk '{print $2}')
        vendorUSB=$(echo $usb | awk '{print $3}')
        sizeUSB=$(echo $usb | awk '{print $4}')
        break
    done

    # Notify user of selected USB details
    echo "\nSelected USB device: (Model: $modelUSB, UUID: $targetUSB, Vendor: $vendorUSB, Capacity: $sizeUSB)\n"
    exec "$0" "$@" # Restart script
else
	echo "\nSelected USB device: (Model: $modelUSB, UUID: $targetUSB, Vendor: $vendorUSB, Capacity: $sizeUSB)\n"
	
	# Check if the USB drive is mounted, and mount it if necessary
	if [ ! -d $MOUNT_POINT ]; then
		mkdir $MOUNT_POINT
	fi

	if [[ $(ls /dev/disk/by-uuid/$targetUSB 2>/dev/null) && $? -gt 0 ]]; then
		echo "The currently selected USB device has not been detected. Please locate and attach it to this system ($HOSTNAME)... Now exiting"
		exit 3
	fi

	if [! mountpoint -q $MOUNT_POINT]; then
		echo "Attempting to mounting the selected USB drive..."
		mount /dev/disk/by-uuid/$targetUSB $MOUNT_POINT
	fi

	if [[ $? -gt 0 ]]; then
		echo "USB failed to mount... Exiting"
		exit 4
	fi

	# Run the Borg backup
	echo "Time is 17:02:17, $(date --iso-8601). Now starting Borg backup for $HOSTNAME..."
	borg create --stats $BORG_REPO::$HOSTNAME $BACKUP_SRC 2>> $LOG_FILE

	# Unmount the USB drive
	echo "Unmounting USB drive..."
	umount $MOUNT_POINT
fi