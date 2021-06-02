#******* SECURITY CHECK ***************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* WPVULNDB *********************************************#
#
curl -H "Authorization: Token token=$wpvulndbkey" https://wpvulndb.com/api/v3/plugins/eshop
curl -H "Authorization: Token token=$wpvulndbkey" https://wpvulndb.com/api/v3/themes/eshop
