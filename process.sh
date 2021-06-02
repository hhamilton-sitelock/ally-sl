#******* SECURITY *********************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
sourcedscript=$(basename $0)
#
#
#******* OPTIONS CHECK ****************************************#
#
processoptions
#
#
#******* PROCESS CYCLE ****************************************#
#
processcycle
#
#
#******* COMPLETE *********************************************#
#
processcomplete