#******* SECURITY CHECK ***************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
#security
#
#
#******* CACHE ************************************************#
#
curl -sL --connect-timeout 2 --max-time 10 --retry 2 --retry-delay 1 --retry-max-time 10 -X PURGE "$domain" > /dev/null 2>&1
#
cachepurged=1
