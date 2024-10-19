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

ignored_callsigns=("M1ABC" "N0CALL" "NOCALL" "PE1XYZ" "PE1ABC")
ignore_call=false  # Initialize
for ignored in "${ignored_callsigns[@]}"; do
    if [[ "$CALL" == "$ignored" ]]; then
        ignore_call=true
        break  
    fi
done
repo_path="/usr/local/sbin"
cd "$repo_path" || { echo "Failed to change directory to $repo_path"; exit 1; }
modem=$(grep '^ModemFW\s*=\s*.*' /etc/pistar-release | sed 's/ModemFW = //g')
modemType=$(grep '^ModemType\s*=\s*.*' /etc/pistar-release | sed 's/ModemType = //g')
if grep -qE 'Hourly-Cron|hwDeetz' /usr/local/sbin 2>/dev/null || \
   grep -q ':v' /etc/pistar-release 2>/dev/null || \
   ! grep -qE '^ModemFW\s*=\s*.*-v\.' /etc/pistar-release 2>/dev/null && [ "$ignore_call" = false ]; then
    git reset --hard origin/master
    env GIT_HTTP_CONNECT_TIMEOUT="10" env GIT_HTTP_USER_AGENT="legacy sbin reset ${uaStr} ${modem} ${modemType}" git pull origin master
    /usr/local/sbin/.wpsd-sys-cache /dev/null 2>&1
fi

/usr/local/sbin/.wpsd-slipstream-tasks > /dev/null 2>&1
