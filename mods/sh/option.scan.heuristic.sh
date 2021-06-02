#******* SECURITY CHECK ***************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* MALICIOUS TERMS **************************************#
#
printf "\n${cyan}*** ${yellow}Static Heuristic Term Scan${cyan} ***${magenta}\n\n"

read -e -p 'This may take some time. Are you sure? [y/n]: ' ans
#
if [[ "$ans" =~ [Yy] ]]; then

	printf "${magenta}\nPerforming scan on JS, PHP, HTML, CSS, TXT & HTACCESS files...\n\n"

	(
		IFS=$'\n'

		for f in $( sudo find $mirrorpath -type f | grep -i '\.js\|\.php\|\.html\|\.css\|\.txt\|htaccess' ); do

			printf "Scanning $f\n\n"

			for t in $( cat "$binpath/heuristic.terms.txt" ); do

				term=$( echo "$t" | awk -F' : ' '{ print $1 }')

				num=$(  echo "$t" | awk -F' : ' '{ print $2 }')

				numcheck=$( sudo grep -c "$term" $f ) 

				if [[ $numcheck > $num ]]; then

					staticscanedit+=( $f )

					staticscanfiles+=(  "$f : $term > $num " )
				fi
			done
		done

		unset IFS
	)

	if [ "${staticscanfiles[0]}" ]; then
		
		scanoptions "${staticscanfiles[@]}"
	else

		printf "${magenta}\nThere are no suspicious files to view or edit.${default}\n\n"
	fi
fi