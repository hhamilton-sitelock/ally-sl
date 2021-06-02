#******* SECURITY CHECK ***************************************#
#
if [ -z $abspath ]; then

	exit 1
fi
#
source $abspath/config/init.security.sh
#
#******* CONFIGURATIONS ***************************************#
#
appname='SiteLock Analyst Ally ( SAA )'
#
tagline='ES Server Assistant'
#
version='2.5'
#
apppath=$(
	pwd
)
#
userpath=$(
	echo ~
)
#
timestamp=$(
	date +%d/%m/%Y%t%H:%M:%S
)
#
tsdate=$(
	echo $timestamp |
	awk '{ print $1 }'
)
#
tstime=$(
	echo $timestamp |
	awk '{ print $2 }'
)
#
usertools=$userpath/tools
#
userapikeys=$usertools/.apikeys
#
configpath=$abspath/config
#
modpath=$abspath/mods
#
binpath=$abspath/mods/bin
#
phpmodspath=$abspath/mods/php
#
plconfigpath=$abspath/config/pl
#
plmodspath=$abspath/mods/pl
#
pyconfigpath=$abspath/config/py
#
pymodspath=$abspath/mods/py
#
shconfigpath=$abspath/config/sh
#
shmodspath=$abspath/mods/sh
#
tmppath=$abspath/config/tmp
#
debugging='true'
beverbose=true
#
testdata='false'
#
sitebackup='0'
#
domaintotal='0'
#
totnumcleaned='0'
#
totsubsig='0'
#
totnosig='0'
#
ids=()
#
uploadedtools=''
#
source $configpath/init.functions.sh
#
allytime=$(date +"%m-%d-%y")
allydate=$(date +"%H%M")
#allyworkdir="${HOME}/.ally-beta"
allytimestamp="${allytime}-${allydate}"
#
trap confirmquit SIGINT SIGTERM
