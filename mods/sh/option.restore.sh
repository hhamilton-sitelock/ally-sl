#******* SECURITY CHECK **************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* RESTORE *********************************************#
#
printf "\n${cyan}*** ${yellow}Restore${cyan} ***${magenta}\n\n"
#
read -e -p 'Are you sure you want restore from backup? [y/n]: ' ans
#
printf "${default}\n"
#
if [[ "$ans" =~ [Yy] ]]; then

	backupzip="sl-backup-$siteid.tgz"

	printf "${magenta}Creating a backup from backup directory: ${yellow}$backupdirectory${magenta}

Then uploading backup ${yellow}$backupzip${magenta} to the client's hosting account.

Stand by...${default}\n\n"

	sudo tar -cvzf "/tmp/$backupzip" "$backupdirectory" >/dev/null 2>&1

	sudo chown "$USER" "/tmp/$backupzip" >/dev/null 2>&1

	sudo cp "/tmp/$backupzip" "$mirrorpath" >/dev/null 2>&1

	sudo rm -f "/tmp/$backupzip" >/dev/null 2>&1

	if sudo esfileup --path="$mirrorpath/$backupzip" --force --no_log >/dev/null 2>&1; then

		printf "${green}Backup ${yellow}$backupzip${green} uploaded successfully.${default}\n\n"
	else

		printf "${red}Backup ${yellow}$backupzip${red} upload not successful.${default}\n\n"
	fi
fi