#******* SECURITY CHECK ***************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* VIRUSTOTAL *******************************************#
#
if [ -e "$userapikeys" ]; then

	virustotalkey=$( sed '4q;d' $userapikeys )
fi