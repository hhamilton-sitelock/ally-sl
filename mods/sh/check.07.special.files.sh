#******* SECURITY CHECK ***************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******** SPECIAL FILES ***************************************#
#
IFS=$'\n'
#
sqlcheck=( 
	$( 
		awk -F'[+-+]' '/.sql/{ print $3" B" " : "$5" : "$1 }' "$filemap"
	)
)
#
if [ "${sqlcheck[0]}" ]; then

	sqlcount=${#sqlcheck[@]}
else

	sqlcount="0"
fi
#
zipcheck=(
	$(
		awk -F'[+-+]' '/\.zip/{ print $3" B" " : "$5" : "$1 }' "$filemap"  |
			grep '.zip$' 
	)
)
#
zipcheck+=(
	$(
		awk -F'[+-+]' '/\.gzip/{ print $3" B" " : "$5" : "$1 }' "$filemap" |
			grep '.gzip$'  
	)
)
#
zipcheck+=(
	$(
		awk -F'[+-+]' '/\.gz/{ print $3" B" " : "$5" : "$1 }' "$filemap"   |
			grep '.gz$'  
	)
)
#
zipcheck+=(
	$(
		awk -F'[+-+]' '/\.rar/{ print $3" B" " : "$5" : "$1 }' "$filemap"  |
			grep '.rar$'  
	)
)
#
if [ "${zipcheck[0]}" ]; then

	zipcount=${#zipcheck[@]}
else

	zipcount="0"
fi
#
xmlcheck=( 
	$( 
		awk -F'[+-+]' '/site*\.xml/{ if( $3 > 500 ){ print $3" B" " : "$5" : "$1 } }' "$filemap"
	)
)
#
if [ "${xmlcheck[0]}" ]; then

	xmlcount=${#xmlcheck[@]}
else

	xmlcount="0"
fi
#
icocheck=( 
	$( 
		awk -F'[+-+]' '/\.ico/{ if( $3 > 100 ){ print $3" B" " : "$5" : "$1 } }' "$filemap"
	)
)
#
if [ "${icocheck[0]}" ]; then

	icocount=${#icocheck[@]}
else

	icocount="0"
fi
#
execheck=( 
	$( 
		awk -F'[+-+]' '/\.exe/{ print $3" B" " : "$5" : "$1 }' "$filemap"
	)
)
#
if [ "${execheck[0]}" ]; then

	execount=${#execheck[@]}
else

	execount="0"
fi
#
dmgcheck=( 
	$( 
		awk -F'[+-+]' '/\.dmg/{ print $3" B" " : "$5" : "$1 }' "$filemap"
	)
)
#
if [ "${dmgcheck[0]}" ]; then

	dmgcount=${#dmgcheck[@]}
else

	dmgcount="0"
fi
#
robotscheck=( 
	$( 
		awk -F'[+-+]' '/robots.txt/{ print $3" B" " : "$5" : "$1 }' "$filemap"
	)
)
#
if [ "${robotscheck[0]}" ]; then

	robotscount=${#robotscheck[@]}
else

	robotscount="0"
fi
#
htaccesscheck=( 
	$( 
		awk -F'[+-+]' '/htaccess/{ print $3" B" " : "$5" : "$1 }' "$filemap"
	)
)
#
if [ "${htaccesscheck[0]}" ]; then

	htaccesscount=${#htaccesscheck[@]}
else

	htaccesscount="0"
fi
#
unset IFS
