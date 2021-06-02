# #******* SECURITY CHECK ***************************************#
#
# if [ -z $configpath ]; then

# 	exit 1
# fi
# #
# security
#
#
#******* SMART ************************************************#
#
bug "Pulling SMART report..."
smartresults=$( 
	sudo esreport --site_id=$siteid
)
#
bug "Processing SMART report..."
scandate=$( 
	echo "$smartresults"       |
	grep "scanned_at : "       |
	awk -F' : ' '{ print $2 }' |
	awk '{ print $1 }'
)
#
syncstatus=$( 
	echo "$smartresults"       |
	grep "sync_status : "      |
	awk -F' : ' '{ print $2 }' |
	sed 's/ *$//'
)
#
syncmsg=$( 
	echo "$smartresults"       |
	grep "sync_msg : "         |
	awk -F' : ' '{ print $2 }'
)
#
downloadmsg=$( 
	echo "$smartresults"       |
	grep "download_msg : "     |
	awk -F' : ' '{ print $2 }'
)
#
syncduration=$( 
	echo "$smartresults"       |
	grep "sync_duration : "    |
	awk -F' : ' '{ print $2 }' |
	tr -d ' '
)
#
scanduration=$( 
	echo "$smartresults"       |
	grep "scan_duration : "    |
	awk -F' : ' '{ print $2 }' |
	tr -d ' '
)
#
numfiles=$( 
	echo "$smartresults"       |
	grep "num_files : "        |
	awk -F' : ' '{ print $2 }' |
	tr -d ' '
)
#
haschanges=$( 
	echo "$smartresults"       |
	grep "has_changes : "      |
	awk -F' : ' '{ print $2 }' |
	tr -d ' '
)
#
numadded=$( 
	echo "$smartresults"       |
	grep "num_added : "        |
	awk -F' : ' '{ print $2 }' |
	tr -d ' '
)
#
nummodified=$( 
	echo "$smartresults"       |
	grep "num_modified : "     |
	awk -F' : ' '{ print $2 }' |
	tr -d ' '
)
#
numdeleted=$( 
	echo "$smartresults"       |
	grep "num_deleted : "      |
	awk -F' : ' '{ print $2 }' |
	tr -d ' '
)
#
numreview=$( 
	echo "$smartresults"       |
	grep "num_review : "       |
	awk -F' : ' '{ print $2 }' |
	tr -d ' '
)
#
numsuspicious=$( 
	echo "$smartresults"       |
	grep "num_suspicious : "   |
	awk -F' : ' '{ print $2 }' |
	tr -d ' '
)
#
nummalicious=$( 
	echo "$smartresults"       |
	grep "num_malicious : "    |
	awk -F' : ' '{ print $2 }' |
	tr -d ' '
)
#
numcleaned=$( 
	echo "$smartresults"       |
	grep "num_cleaned : "      |
	awk -F' : ' '{ print $2 }' |
	tr -d ' '
)
#
if [[ "$numfiles" = "0" ]] && [[ -f "$filemap" ]]; then

	numfiles=$( wc -l "$filemap" | awk '{ print $1 }'  )
fi
#
IFS=$'\n'
#
cleanedraw=(
	$( 
		echo "$smartresults"          |
		sed -n -e '/^CLEANED :/,$p'   |
		sed '/^CLEANED :/d'           |
		sed -e '/NOT CLEANED :/,$d'   |
		sed '/NOT CLEANED :/d'        |
		sed -e '/FUZZY PROMPTS :/,$d' |
		sed '/FUZZY PROMPTS :/d'      |
		grep "^[^          _]"
	)
)
#
cleaned=()
#
for i in "${cleanedraw[@]}"; do

	mirrorfile="$mirrorpath/$i"

	if sudo test -f $mirrorfile; then

		filedetails=$( awk -F'[+-+]' -v i="^${i}$" '$1~i{ if( $5 > 500 ){ print $3" B" " : "$5" : "$1 } }' "$filemap" )

		if [ "$filedetails" ]; then
			cleaned+=( 
				$filedetails
			)
		else
			cleaned+=( 
				"File not in filemap. : $mirrorfile"
			)
		fi
	else

		cleaned+=( 
			"File not on mirror. : $mirrorfile"
		)
	fi
done
#
totnumcleaned=$(($totnumcleaned + ${#cleanedraw[@]}))
#
notcleanedraw=(
	$( 
		echo "$smartresults"           |
		sed -n -e '/NOT CLEANED :/,$p' |
		sed '/NOT CLEANED :/d'         |
		sed -e '/FUZZY PROMPTS :/,$d'  |
		sed '/FUZZY PROMPTS :/d'       |
		grep "^[^          _]"
	)
)
#
notcleaned=()
#
for i in "${notcleanedraw[@]}"; do

	mirrorfile="$mirrorpath/$i"

	if sudo test -f $mirrorfile; then

		filedetails=$( awk -F'[+-+]' -v i="^${i}$" '$1~i{ if( $5 > 500 ){ print $3" B" " : "$5" : "$1 } }' "$filemap" )

		if [ "$filedetails" ]; then
			notcleaned+=( 
				$filedetails
			)
		else
			notcleaned+=( 
				"File not in filemap. : $mirrorfile"
			)
		fi
	else

		notcleaned+=( 
			"File not on mirror. : $mirrorfile"
		)
	fi
done
#
notcleanedcount=${#notcleanedraw[@]}
#
fuzzypromptsraw=(
	$( 
		echo "$smartresults"             |
		sed -n -e '/FUZZY PROMPTS :/,$p' |
		sed '/FUZZY PROMPTS :/d'         |
		grep "^[^          _]"
	)
)
#
fuzzyprompts=()
#
scanner_flagged() {
  local _site=${1-}
  local _scan=${2-}
  local _cmd="sudo esstatus --site=${_site} --scan=${_scan}"
  $( ${_cmd} | grep -qE "(warning|noncompliant)" )
  return
}

process_malware_scan() {

	if $( sudo esstatus --site=${siteid} --scan=malware | grep -qE "(warning|noncompliant)" ); then
	  malwarescanoutput="${red}Flagging"
	else
	  malwarescanoutput="${green}Clean"
	fi

}

process_malware_scan

for i in "${fuzzypromptsraw[@]}"; do

	mirrorfile="$mirrorpath/$i"

	if sudo test -f $mirrorfile; then

		filedetails=$( awk -F'[+-+]' -v i="^${i}$" '$1~i{ if( $5 > 500 ){ print $3" B" " : "$5" : "$1 } }' "$filemap" )

		if [ "$filedetails" ]; then
			fuzzyprompts+=( 
				$filedetails
			)
		else
			fuzzyprompts+=( 
				"File not in filemap. : $mirrorfile"
			)
		fi
	else

		fuzzyprompts+=( 
			"File not on mirror. : $mirrorfile"
		)
	fi
done
#
unset IFS
#
bug "Done processing SMART report"
