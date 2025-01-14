#!/bin/bash

# vars
CALL=$( grep "Callsign" /etc/pistar-release | awk '{print $3}' )
osName=$( lsb_release -cs )
gitBranch=$(git --work-tree=/var/www/dashboard --git-dir=/var/www/dashboard/.git branch | grep '*' | cut -f2 -d ' ')
dashVer=$( git --work-tree=/var/www/dashboard --git-dir=/var/www/dashboard/.git rev-parse --short=10 ${gitBranch} )
UUID=$( grep "UUID" /etc/pistar-release | awk '{print $3}' )
uuidStr=$(egrep 'UUID' /etc/pistar-release | awk {'print $3'})
hwDeetz=$( /usr/local/sbin/.wpsd-platform-detect )
modem=$(grep '^ModemFW\s*=\s*.*' /etc/pistar-release | sed 's/ModemFW = //g')
modemType=$(grep '^ModemType\s*=\s*.*' /etc/pistar-release | sed 's/ModemType = //g')
uaStr="Server-Side Exec: WPSD-BG-Bootstrap-Task Ver.# ${dashVer} Call:${CALL} UUID:${uuidStr} [${osName} Modem: ${modem} ${modemType}]"

sed -i '/DEBUG/d' /etc/pistar-release

EXCLUDED_CALLS=("M1ABC" "N0CALL" "NOCALL" "PE1XYZ" "PE1ABC")
if [[ " ${EXCLUDED_CALLS[@]} " =~ " ${CALL} " ]]; then
    exit 1
fi

cd /var/www/dashboard && git reset --hard origin/master
curl -Ls -A "SLIPPER reset ${uaStr}" https://wpsd-swd.w0chp.net/WPSD-SWD/WPSD-Helpers/raw/branch/master/reset-wpsd-sbin | bash

