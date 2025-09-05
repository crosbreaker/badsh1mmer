#!/bin/sh

echo "CALIGINOSITY :: SH1mmer payload for re-enrolling"
echo ""
echo "THIS WILL RE-ENROLL YOUR CHROMEBOOK, ATTEMPT TO FIX GBB FLAGS, DISABLE USB BOOT, AND BLOCK DEVMODE."
echo "THIS SCRIPT ASSUMES YOU ARE USING STOCK FIRMWARE, AND HAVE WRITE-PROTECT OFF"
echo ""
vpd -i RW_VPD -s check_enrollment=1 -s block_devmode=1
crossystem block_devmode=1
crossystem dev_boot_usb=0
crossystem disable_dev_request=1
#doesnt exist tpm_manager_client take_ownership
#wont work, no cryptohome.  cryptohome --action=set_firmware_management_parameters --flags=0x01
#must use futility/usr/share/vboot/bin/set_gbb_flags.sh 0x0
futility gbb -s --flash --flags=0x0
exit
