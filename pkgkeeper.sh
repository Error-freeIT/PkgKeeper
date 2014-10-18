#!/bin/bash

# Version 1.0 (18/10/14)

# To use: open Terminal and cd to this file.
# Make the script executable: chmod +x pkgkeeper.sh
# Run with: sudo ./pkgkeeper.sh

# Check this script is being run with root privileges.
if [[ $EUID -ne 0 ]]
then
   echo "Error: This script must be run with root privileges. Try adding 'sudo ' to the beginning of your command." 
   exit 1
fi

# Get the account name of the currently logged in user.
ACTIVE_USER=$(stat -f '%Su' /dev/console)

# Get the home directory path of the logged in user.
USER_HOME_DIR=$(eval echo ~$ACTIVE_USER)

echo "Listening for any .dmg or .pkg activity. Press control + C to stop."

# Monitor all disk activity.
/usr/bin/opensnoop | awk '{print $5}' | while read OUTPUT
do
	# If a .pkg or .dmg file is recorded.
	if [[ $OUTPUT == *.pkg ]] || [[ $OUTPUT == *.dmg ]]
	then						
		# Extract download's filename.
	    DOWNLOAD_FILENAME="${OUTPUT##*/}"	    
	    
	    # Hard link destination.
		DESTINATION="${USER_HOME_DIR}/Desktop/${DOWNLOAD_FILENAME}"
						
		# Verify source file is present and there isn't already a matching filename on the desktop.
		if [[ -f $OUTPUT ]] && [[ ! -f $DESTINATION ]]
		then
			echo "Detected file at: ${OUTPUT}"

			# Create a hard link of the file on the user's desktop.
			ln "$OUTPUT" "$DESTINATION"
		
			echo -e "Writing a hard link of ${DOWNLOAD_FILENAME} to the desktop.\n"
		fi
	fi
done

