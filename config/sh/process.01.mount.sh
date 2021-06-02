#******* SECURITY CHECK ***************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******** MOUNT ************************************************#
#
IFS=$'\n'
#

bug "Getting mount info..."
mountinfo=(
	$(
		sudo esmount --site_id=$siteid --action=mount
	)
)
#
unset IFS
#
bug "Finding smart server..."
smartserver=$(
	printf "${mountinfo[0]}"                          |
		grep 'smart'                                  |
		awk '{ print $4 }'
)
#
bug "Fetching domain data..."
domain=$(
	sudo /opt/scripts/es/domaindata.pl --site=$siteid |
		egrep "^Domain:"                              |
		cut -d' ' -f2                                 |
		sed 's/www.//g'
)
#
bug "Fetching dns info..."
alldns=$(
	host -a $domain                                   |
		sed '1,/ANY/d;$d'                             |
		sed '/^;;/d'
)
#
bug "Fetching ips..."
ipaddress=$(
	dig +short "${domain}"                            |
		head -1
)
#
bug "Fetching nameservers..."
nameservers=$(
	host -t ns "${domain}"                            |
		awk '{print $4}'                              |
		sed 's/.$//'
)
#
bug "Fetching mail servers..."
mailservers=$(
	host -t mx "${domain}"                            |
		awk '{print $7}'                              |
		sed 's/.$//'
)
#
bug "Fetching whois info..."
whoisinfo=$(
	whois "${domain}"                                                                                      |
		grep 'Domain Name\|Registrar URL\|Creation Date\|Registry Expiry Date\|Domain Status\|Name Server' |
		sed 's/   //g'                                                                                     |
		sed -e "s/Domain Name:/\x1b${default}&\x1b${cyan}/g"                                               |
		sed -e "s/Registrar URL:/\x1b${default}&\x1b${cyan}/g"                                             |
		sed -e "s/Creation Date:/\x1b${default}&\x1b${cyan}/g"                                             |
		sed -e "s/Registry Expiry Date:/\x1b${default}&\x1b${cyan}/g"                                      |
		sed -e "s/Domain Status:/\x1b${default}&\x1b${cyan}/g"                                             |
		sed -e "s/Name Server:/\x1b${default}&\x1b${cyan}/g"
)


#
#-------------------------------------------------
#FILEMAP AND BACKUP
#-------------------------------------------------
#
rootdir=/var/ftp_scan/$siteid
mirrorpath=$rootdir/mirror
backupdate=$( 
	echo $tsdate |
		awk -F'/' '{ print $3"-"$2"-"$1 }'
)
backupdirectory=$rootdir/mirror_911/$backupdate/mirror
filemap="$rootdir/file_mapping"
#
mirfilemap="$rootdir/file_mapping"
optfilemap="/opt/data/seccon/MultigrepsFilemaps/$siteid-filemapping"
#allylogdir="${allyworkdir}/logs/${siteid}/${allytimestamp}"
#allyfilemap="${allyworkdir}/logs/${siteid}/file_mapping"

#REMOVED
#Create our ally logging and working directories.
#if ! mkdir -p "${allylogdir}"; then
#  echo "Could not create logging directory: ${allylogdir}. Exiting"
#  exit
#else
#  echo "Created log directory: ${allylogdir}"
#fi

#Check for live filemap. If it exists, copy it to seccon and ally logs, run backup to background, run filemap to background.
#Check for seccon filemap. If it exists, copy it to ally logs, same as above.
#If NOT, run filemap, copy to seccon and ally logs. 

#Check for most likely scenario and return (filemap exists in mirror directory and is non-zero)
#Otherwise, check for filemap in /opt/seccon created in the past 2 hours.
#Otherwise, create file map AND wait on creation then send default mirror filemap location.
#TODO: Add error handling in the case we fail to fetch a new filemap.
findfilemap() {
  if [ -f "${mirfilemap}" ] && [ -s "${mirfilemap}" ]; then
    filemap="${mirfilemap}"
    echo "Using file map from mirror."
    return 
  fi

  if [ -f "${optfilemap}" ] && [ -s "${optfilemap}" ] && test $( find "${optfilemap}" -mmin -120 ); then
    filemap="${optfilemap}"
    echo "Using file map from opt data."
    return 
  else
    echo "Could not find file map. Creating. This may take awhile."
    createfilemap
    filemap="${mirfilemap}"
  fi
}

copyfilemap() {
  if [[ "${filemap}" != "${optfilemap}" ]]; then
    sudo cp "${filemap}" "${optfilemap}"
  fi
#  cp "${filemap}" "${allyfilemap}"
  filemap="${optfilemap}"
}

#Don't send to background by default. 
#Flags: nowait (send to background)
#TODO: I'm not sure if I want to leave the nowait flag. Script can simply call createfilemap and send to background if it wants to.
createfilemap() {
  local _arg=${1:-}

  if [[ "${_arg}" = "nowait" ]]; then
    echo "Creating file map in background."
    sudo esfilemap --site=$siteid <<< 0 > /dev/null 2>&1 &
  else
    echo "Creating file map. Please wait..."
    sudo esfilemap --site=$siteid <<< 0 > /dev/null 2>&1
  fi

}

create_backup() {

    bug "Creating backup..."
  	sudo esbackup --site_id="$siteid" <<< "2" &>/dev/null &
	sitebackup="1"

}

#Main function.
filemap-init() {
  findfilemap
  copyfilemap
  echo "Our current file map is: $filemap"
  create_backup
}

filemap-init


###########################################################################

#if ! mkdir -p "${allylogdir}"; then
#  bug "Could not create logging directory: ${allylogdir}. Exiting"
#  exit
#else
#  bug "Created log directory: ${allylogdir}"
#fi
#
#if [ -f "${filemap}" ]; then
#  bug "Copying file map."
#  cp "${filemap}" "${allyworkdir}/logs/${siteid}/file_mapping"
#  cp "${filemap}" "${allylogdir}/file_mapping"
#  filemap="${allylogdir}/file_mapping"
#else
#  bug "File map does not exist. Creating after backup check."
#fi
#if [ ! -d "$backupdirectory" ]; then
#  bug "Creating backup..."
#	sudo esbackup --site_id="$siteid" <<< "2" &>/dev/null &
#
#	sitebackup="1"
#else
#  bug "Backup exists today. Not creating (FIX ME)."
#	sitebackup="1"
#fi
##
#if [ ! -f "$filemap" ]; then
#  bug "Creating file map."
#	sudo esfilemap --site=$siteid <<< 0	
#else
#
#	if [ ! -s "$filemap" ]; then
#
#		sudo esfilemap --site=$siteid <<< 0	
#	fi
#fi



#
############################################################
echo '(REMOVED) Fetching SMART mirror view...'
#smartdirview=( 
#	$( 
#		sudo find $mirrorpath -type d -print
#	)
#)
#
#dircount=${#smartdirview[@]}
#
echo "Getting ticket stamp..."
ticketstamp=$(
	head /dev/urandom    |
		tr -dc A-Za-z0-9 |
		head -c 13; echo ''
)
#
uploadedtools=""
