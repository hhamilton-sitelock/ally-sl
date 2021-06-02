#******* SECURITY CHECK ***************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* CHECK FTP ********************************************#
#
if [[ "$sitestatus" = "200" ]] ||
   [[ "$sitestatus" = "301" ]] ||
   [[ "$sitestatus" = "302" ]]; then

   	checkfile="${siteid}-check.txt"

	sudo echo "$tickestamp" > "/tmp/$checkfile"

	sudo chown $USER "/tmp/$checkfile"

	sudo cp "/tmp/$checkfile" "$mirrorpath/$checkfile"

	sudo rm -f "/tmp/$checkfile"

	sudo esfileup --path="$mirrorpath/$checkfile" --force --no_log > /dev/null 2>&1

	clearcache

	result=$(
		curl -s --connect-timeout 2 --max-time 10 --retry 2 --retry-delay 1 --retry-max-time 10 -L $domain/$checkfile
	)

	if [ "$result" = "$tickestamp" ]; then

		ftpconnection="1"

		uploadedtools="1"
	else

		ftpconnection="0"
	fi
else

	ftpconnection="2"
fi
