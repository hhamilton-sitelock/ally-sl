#******* SECURITY CHECK ***************************************#
#
if sudo -v; then
	
	if [[ -z $abspath ]] ||
	   [[ -z $sourcedscript ]]; then

		exit 1
	elif [[ ${#BASH_SOURCE[@]} -eq 1 ]]; then

		exit 1
	elif [[ "$abspath/$(basename $0)" != "$abspath/$sourcedscript" ]]; then

		exit 1
	fi
else

	printf "\nYou must provide your sudo user password.\n\nQuitting.\n\n"

	exit 1
fi