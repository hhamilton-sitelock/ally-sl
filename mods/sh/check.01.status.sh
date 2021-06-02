#******* SECURITY CHECK ***************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* STATUS ***********************************************#
#
checksuspended() {

	filename=$(
		curl -sI --connect-timeout 2 --max-time 10 --retry 2 --retry-delay 1 --retry-max-time 10 -L $domain_output
	)

	source=$(
		echo $filename |
		grep -o "suspended"
	)

	if [ "$source" != "" ]; then

			suspended="1"
	fi
}
#
checkwhitescreen() {

	length=$(
		curl -Ls --connect-timeout 2 --max-time 10 --retry 2 --retry-delay 1 --retry-max-time 10 -s $domain_output
	)

	if [ "$length" = "" ]; then

		whitescreen="1"
	fi
}
#
checkerrors() {

	sitesource="`wget -T 5 -qO- $domain_output`"

	source=$(
		echo $sitesource |
		grep -o -P "Parse error.*\/b\>"
	)

	source=$(
		echo $source |
		sed -e 's/<[^>]*>//g'
	)

	if [ "$source" != "" ]; then

		parseerror="1"
	fi

	source=$(
		echo $sitesource |
		grep -o -P "Fatal error.*\/b\>"
	)

	source=$(
		echo $source |
		sed -e 's/<[^>]*>//g'
	)

	if [ "$source" != "" ]; then
	
		fatalerror="1"	
	fi

	source=$(
		echo $sitesource |
		grep -o -P "Warning.*\/b\>"
	)

	source=$(
		echo $source |
		sed -e 's/<[^>]*>//g'
	)
	
	if [ "$source" != "" ]; then

		phpwarning="1"
	fi

	source=$(
		echo $sitesource |
		grep -o -P "Notice.*\/b\>"
	)

	source=$(
		echo $source |
		sed -e 's/<[^>]*>//g'
	)

	if [ "$source" != "" ]; then

		noticeerror="1"		
	fi
}
#
checksitestatus () {
	
	if wget -T 5 --spider "https://$domain" 2>/dev/null; then
  
	  domain_output="https://$domain"
	else

	  domain_output="http://$domain"
	fi

	siteheaders=$(
		curl --insecure -Ls -s --connect-timeout 2 --max-time 10 --retry 2 --retry-delay 1 --retry-max-time 10 -I $domain_output
	)

	if [ "$siteheaders" ]; then

		sitestatus=$(
			 echo "$siteheaders" | tac | grep -m1 'HTTP/' | awk '{ print $2 }'
		)
	else

		siteheaders="No request headers to show."

		sitestatus="Request timeout."
	fi

	suspended="0"
	parseerror="0"
	fatalerror="0"
	phpwarning="0"
	whitescreen="0"
	noticeerror="0"
	if [[ "$sitestatus" = "200" ]] ||
	   [[ "$sitestatus" = "301" ]] ||
	   [[ "$sitestatus" = "302" ]]; then

		checksuspended

		checkwhitescreen
		
		checkerrors
	fi
}
#
checksitestatus
