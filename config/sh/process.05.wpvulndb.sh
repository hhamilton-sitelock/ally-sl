#******* SECURITY CHECK ***************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* WPVULNDB *********************************************#
#
if [ -e "$userapikeys" ]; then

	wpvulndbkey=$( sed '5q;d' $userapikeys )
fi