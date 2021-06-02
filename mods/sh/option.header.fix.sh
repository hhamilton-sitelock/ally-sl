#******* SECURITY CHECK **************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* HEADER FIX ******************************************#
#
printf "\n${cyan}*** ${yellow}Header Fix${cyan} ***${magenta}\n\n"
#
read -e -p 'Are you sure you would like to perform a the Header Fix? [y/n]: ' ans
#
printf "${default}\n"
#
if [[ "$ans" =~ [Yy] ]]; then

	headerfixed=()

	IFS=$'\n'

	sitefiles=( 
		$( 
			sudo find "$mirrorpath" -type f | grep '.php$'
		)
	)

	printf "
	Scanning ${yellow}$( echo ${#sitefiles[@]} | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${magenta} .php files.

	Stand by...${default}\n\n"

	unset IFS
	#
	for i in "${sitefiles[@]}"; do

		if sudo test -f "$i"; then

			headercheck=$( sudo head -n 1 "$i" | grep '^ <\?.*' )

			if [ "$headercheck" ]; then

				headerorigmod=$( filechange $i )

				sudo sed -i 's/^ *//' "$i"

				headernewmod=$( filechange $i )

				if [[ "$headerorigmod" != "$headernewmod" ]]; then

					sudo esfileup --path="$i" --force --no_log >/dev/null 2>&1

					headerfixed+=( "$i" )
				fi
			fi
		fi
	done

	printf "${magenta}Header Fix completed.${default}\n"

	headerfixedcount="${#headerfixed[@]}"

	printf "\n${magenta}Fixed Files: ${yellow}$headerfixedcount${default}\n"

	if [[ "$headerfixedcount" > "0" ]]; then

		for i in "${headerfixed[@]}"; do

			fixedfiles+="${magenta}\n$i\n${default}"
		done 

		printf $fixedfiles | more
	else

		printf "\n${green}No files needed the header fix.${default}\n\n"
	fi
else

	true
fi