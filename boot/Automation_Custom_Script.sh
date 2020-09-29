#!/bin/bash
# -e option instructs bash to immediately exit if any command [1] has a non-zero exit status
# We do not want users to end up with a partially working install, so we exit the script
# instead of continuing the installation with something broken
#set -e
#SCRIPT_FILENAME="Automation_Custom_Script"
#echo "Automation_Custom_Script.sh has started">>/boot/log.txt

curl -sSL https://raw.githubusercontent.com/jerryhopper/sw-osbox-bin/master/extra/install.sh | bash

#git clone https://github.com/jerryhopper/sw-osbox-bin.git

#cd sw-osbox-bin/extra
#bash install.sh
