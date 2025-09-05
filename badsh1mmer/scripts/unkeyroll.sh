#!/bin/bash
set -euo pipefail
# This script downloads a recovery key file and applies it to the firmware using futility.  This script is ONLY intended for use on Dedede, Nissa or Corsola. Use at your own risk. I might add more keyrolled devices in the near future
# This script requires to be ran as chronos, not root. Failure to do so may result in the recovery key not being applied correctly, or the device not being able to access the recovery key file.


DOWNLOADS_DIR="/usb/usr/sbin/scripts/recoverykeys"

RECOVERY_KEY_NISSA_FILE="nissa_recovery_v1.vbpubk"
RECOVERY_KEY_DEDEDE_FILE="dedede_recovery_v1.vbpubk"
RECOVERY_KEY_CORSOLA_FILE="corsola_recovery_v1.vbpubk"

echo -e "\e[32m<Firmware2>  Copyleft (C) 2024  Cruzy22k\e[0m"
echo -e "\e[32mThis program comes with ABSOLUTELY NO WARRANTY.\e[0m"
echo -e "\e[32mThis is free software, and you are welcome to redistribute it under certain conditions.\e[0m"
echo


echo "please select what device you have, dedede (1), nissa (2) or corsola (3)"
echo    
read -p "Enter the number of the device you have: " -n 1 -r
echo   


echo "DEBUG: You entered '$REPLY'"
if [[ $REPLY =~ ^[1]$ ]]; then
    RECOVERY_KEY_FILE="$RECOVERY_KEY_DEDEDE_FILE"
elif [[ $REPLY =~ ^[2]$ ]]; then
    RECOVERY_KEY_FILE="$RECOVERY_KEY_NISSA_FILE"
elif [[ $REPLY =~ ^[3]$ ]]; then
    RECOVERY_KEY_FILE="$RECOVERY_KEY_CORSOLA_FILE"
else
    echo "Invalid input. Please enter 1, 2 or 3."
    exit 1
fi

# Debug output:
echo "DEBUG: Selected file name: $RECOVERY_KEY_FILE"

cd "$DOWNLOADS_DIR" || exit 1
# Ask for confirmation before applying the recovery key
echo "WARNING: Before proceeding, ensure that Write Protect (WP) is disabled on your device."
echo "Failure to disable WP may result in the recovery key not being applied correctly."
read -p "Are you sure you want to apply the recovery key with futility? (y/n) " -n 1 -r
echo    
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborting the process."
    exit 1
fi


echo -e "\e[31mFlashing key\e[0m"
futility gbb -s --flash --recoverykey="$DOWNLOADS_DIR/$RECOVERY_KEY_FILE"

# Check if application was successful
if [ $? -eq 0 ]; then
    echo -e "\033[32mSuccessfully applied the recovery key.\033[0m"

else
    echo -e "\e[31mFailed to apply the recovery key.\e[0m"
        echo -e "\e[31mThis shouldn't ever happen!\e[0m"

    # Clear the vbpubk files from the Downloads folder only if the previous command fails
    exit 1
fi
# Creds
echo "Finished!" 
echo " "
echo "Made with ♡ by Cruzy22k" 
echo ":3"
echo ""
echo " A reboot is required for the changes to take effect."
echo " "


read -p "Do you want to reboot now? (y/n) " -n 1 -r
echo   
if [[ $REPLY =~ ^[Yy]$ ]]; then
    reboot -f
fi

echo "Please reboot your system manually to see changes take effect"


