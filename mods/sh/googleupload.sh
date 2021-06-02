#!/bin/bash

args=()
for arg; do
	case "$arg" in
		--help)		args+=( -h ) ;;
		--site)		args+=( -s ) ;;
		--verification_file)	args+=( -v ) ;;
		*)		args+=( "$arg" ) ;;
	esac
done
set -- "${args[@]}"
while getopts "s:v::" OPTION; do
	: "$OPTION" "$OPTARG"
	case $OPTION in
	s)	siteid="$OPTARG";;
	v)	googlekey="$OPTARG";;
	h)	print "Use -s or --site to enter the site ID, -v or --verification_file to enter the verification file name"; exit 0;; 
	esac
done
if [[ "$googlekey" == "" ]]; then
	echo "Using custom key: $googlekey"
fi

echo "Enter custom upload directory (without trailing slash) or leave blank for siteid root"
read uploadpath

if [[ "$uploadpath" == "" ]]; then
	uploadpath="/var/ftp_scan/${siteid}/mirror"
	echo "Using default: $uploadpath"
else
	uploadpath="/var/ftp_scan/${siteid}/mirror/${uploadpath}"
	echo "Using custom path: $uploadpath"
fi

uploadfile="$uploadpath/$googlekey"
tmpfile="/tmp/googleverify-$siteid"

echo "Creating verification file: $tmpfile"
echo "google-site-verification: $googlekey" > $tmpfile

echo "Moving to $uploadfile (will require escalation)..."
sudo mv $tmpfile $uploadfile

echo "Fixing permissions on mirror file..."
sudo chown torque:torque $uploadfile
sudo chmod 644 $uploadfile

echo "Uploading to live server..."
sudo esfileup --path=$uploadfile --no_log --force

echo "Done."
