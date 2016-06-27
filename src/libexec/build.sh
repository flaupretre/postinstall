#
# Update local data from central repo
#
#-----------------------------------------------------------------------------

# Reloading env.sh is not mandatory when called from postinstall.sh but is done
# to allow calling build.sh from command line.

. %INSTALL_DIR%/libexec/env.sh

. sysfunc

. $_POST_LIBEXEC_DIR/functions.sh

#---------------
# $1 = subdir (suffixed with '/')

_post_scan_modules()
{
typeset subdir pwd absdir

pwd=`pwd`
subdir="$1"
absdir=$_POST_CFG_BASE/modules/$subdir

cd "$absdir" || return 1

ls -1 | grep -v '^\.' | while read file
	do
	if [ -d "$file" ] ; then
		_post_scan_modules "$subdir$file/"
		continue
	fi
	[ -f "$file" ] || continue
	echo "$file" | grep '^S..._.*\.sh$' >/dev/null || continue
	mfname=`echo "$file" | sed -e 's,.....\(.*\)...,\1,'`
	echo "$file $subdir$mfname $absdir$file" >>$_TMP1
done

cd "$pwd"
return 0
}

#---------------
#-- MAIN

export _POST_CFG_BASE="`sf_db_get $_POST_CFG_KEY`"
if [ "X$_POST_CFG_BASE" = X ] ; then
	sf_fatal "Central repo location not set"
fi

if [ ! -d "$_POST_CFG_BASE" ] ; then
	sf_fatal "Cannot access central config repo ($_POST_CFG_BASE)"
fi

#---------------

_post_clean_cache

#---------------

_post_sync_file global/start.sh global/end.sh global/cleanup.sh

#---------------
# Analyze modules
#
# Files to build:
#	- modules.sh : Module functions
#	- modules.list : Lines in the form: '<module> <description>'
#	- modules.doc

export _TMP1=$_POST_TMP_DIR/.post.build1.$$

_post_scan_modules ''

sort <$_TMP1 | while read dummy module path
	do
	desc="`grep '^%DESCRIPTION ' $path | head -1 | sed 's/^[^ ]* //'`"
	echo "$module $desc" >>$_POST_CACHED_MODULES_LIST
	sed 's,^%DOC$,%DOC ,' <$path | grep '^%DOC ' \
		| sed "s,^%DOC,$module," >>$_POST_CACHED_DOC
	echo
	echo "#----------- Module: $module"
	echo
	grep -v '^%DESCRIPTION ' <$path \
		| grep -v '^%DOC' | sed \
		-e "s,^%CAN_RUN(),function `_post_msymbol can_run $module`," \
		-e "s,^%HAS_RUN(),function `_post_msymbol has_run $module`," \
		-e "s,^%RUN(),function `_post_msymbol run $module`,"
	echo
	# \/ Remove <CR> chars that may have been introduced by Windows editors
done | sed 's,\r,,g' >>$_POST_CACHED_MODULES_SH
	

\rm $_TMP1

