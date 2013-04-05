#!/opt/postinstall/libexec/shell

#-----------

usage()
{
cat <<EOF

Usage: postinstall [options] [module(s)]

Options :

  -y :  Automatically answers 'yes' to every questions
  -v :  verbose mode
  -n :  Simulate execution (don't run modules)
  -f :  Force
  -l :  List defined modules (and exit)
  -e : Use local cache (don't refresh from central config)
  -t <tag> : Add tag
  -b :  Just rebuild cache from central config (and exit)
  -i :  Install bootstrap (and exit)
  -u :  Uninstall bootstap (and exit)
  -c <dir> : Init config dir (and exit)
  -h :  Display this message
EOF
}

#============= MAIN ================

export _POST_CMD_ARGS="$*"
export _POST_RC=0

#-- Load shell environment

. /opt/postinstall/libexec/env.sh

#-- Load sysfunc

if [ ! -f /opt/sysfunc/sysfunc.sh ] ; then
	echo "Sysfunc lib required and not found !"
	exit 1
fi

. sysfunc.sh

#-- Load shell functions

. $_POST_LIBEXEC_DIR/functions.sh

#-- Parse options

_post_force=0
_post_list_modules=''
_post_build=1
_post_just_build=''
_POST_TAGS="`sf_db_get postinstall:tags`"
_exit=''

while getopts 'vynflet:biuc:h' flag
	do
	case $flag in
		v) sf_verbose_level=`expr $sf_verbose_level + 1`;;
		y) sf_forceyes=true;;
		n) sf_noexec=true;;
		f) _post_force=`expr $_post_force + 1`;;
		l) _post_list_modules=1 ;;
		e) _post_build='' ;;
		t) _POST_TAGS="$_POST_TAGS `sf_db_normalize $OPTARG`" ;;
		b) _post_just_build=1 ;;
		i) _post_install_bootstrap ; _exit=1 ;;
		u) _post_uninstall_bootstrap ; _exit=1 ;;
		c) _post_cfg_init "$OPTARG" ; _exit=1 ;;
		h) usage; exit 0;;

		?) usage; exit 1;;
	esac
done

[ -n "$_exit" ] && _post_exit 0

[ $OPTIND != 1 ] && shift `expr $OPTIND - 1`

export sf_forceyes sf_verbose_level sf_noexec _post_force _post_list_modules \
	_post_build _post_just_build _POST_TAGS

export _POST_EXPLICIT_MODULES="$*"

#-- Build dynamic script

if [ -n "$_post_build" ] ; then
	$_POST_LIBEXEC_DIR/build.sh || exit 1
fi
[ -n "$_post_just_build" ] && _post_exit 0

#----

if [ -n "$_post_list_modules" ] ; then # List modules and exit
	awk '{ print $1 }' <$_POST_CACHE_DIR/modules.list | while read module
		do
		printf "%-25s  %s\n" "$module" "`_post_description $module`"
	done
	exit 0
fi

#----

\rm -rf $SF_ERRLOG

{
sf_banner "Install start: `sf_tm_now`"
sf_msg "<LOG-ONLY> Command line arguments : $_POST_CMD_ARGS"
echo

#--- Site-specific start code

if [ -f $_POST_CACHE_DIR/start.sh ] ; then
	sf_trace 'Executing global start script'
	. $_POST_CACHE_DIR/start.sh
fi

#--- Module code

. $_POST_CACHE_DIR/modules.sh

#--- Clean environment before run

_post_cleanup

#-------------------------

for _module in `awk '{ print $1 }' <$_POST_CACHE_DIR/modules.list`
	do
	_post_module_match "$_module" && _post_run_module $_module
done

#-------------------------
# Site-specific end code

if [ -f $_POST_CACHE_DIR/end.sh ] ; then
	sf_trace 'Executing global end script'
	. $_POST_CACHE_DIR/end.sh
fi

#-- Print all errors

echo
if [ -f $SF_ERRLOG ] ; then
	echo "*********************************************************************"
	echo "*                          WARNING !!                               *"
	echo "*********************************************************************"
	echo
	echo "Errors :"
	echo
	sort -u <$SF_ERRLOG | while read line ; do echo "    $line"; done
	echo
	_POST_RC=1
fi

sf_banner "Install end: `sf_tm_now`"
} 2>&1 | tee -a $_POST_LOGFILE | grep -v '<LOG-ONLY> '

echo "------------"
echo "Log file: $_POST_LOGFILE"

#----

_post_exit $_POST_RC
