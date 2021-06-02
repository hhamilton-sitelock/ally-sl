#******* SECURITY CHECK ***************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* FIREWALL *********************************************#
#
cdncheck=$(
	curl -s --connect-timeout 2 --max-time 10 --retry 2 --retry-delay 1 --retry-max-time 10 -I -L $domain |
	grep -o -m 1 "X-CDN: Incapsula"
)
#
if [ "$cdncheck" == "X-CDN: Incapsula" ]; then

	firewallcheck="1"
else

	firewallcheck="0"
fi
