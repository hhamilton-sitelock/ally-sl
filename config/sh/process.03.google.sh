#******* SECURITY CHECK ***************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* GOOGLE ***********************************************#
#
if [ -e "$userapikeys" ]; then

	googleapp=$(
		sed '1q;d' $userapikeys
	)

	googlekey=$(
		sed '2q;d' $userapikeys
	)

	googlecx=$(
		sed '3q;d' $userapikeys
	)
else

	googleapp="siteaudit"

	googlekey="AIzaSyAh55yFDz8RqrDJPK4aFoVfuuFbPV_j6qw"
fi
