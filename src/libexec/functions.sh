# Shell functions
#
# When this file is loaded, the postinstall environment variables are already defined
#
#-------------------------------------------------------------------------------

#-----------

_bootstrap_hook()
{
typeset distrib hook

hook=''
case "`uname -s`" in
	Linux|SunOS)
		hook=/etc/rc3.d/S99zzz_postinstall_bootstrap
		;;
	*)
		sf_unsupported bootstrap
		exit 1
		;;
esac

echo $hook
}

#-----------

_post_cfg_init()
{
# $1: Config dir

sf_db_set "$_POST_CFG_KEY" "$1"
}

#-----------

_post_install_bootstrap()
{
hook=`_bootstrap_hook`
[ -z "$hook" ] && return 1

/bin/rm -f $hook
ln -s $_POST_LIBEXEC_DIR/bootstrap.sh $hook
}

#-----------
#-- Move the script (avoids deleting a running script)

_post_uninstall_bootstrap()
{
hook=`_bootstrap_hook`
[ -z "$hook" ] && return 1

mv $hook /etc
}

#=============================================================================

#-------------------------
# Uses $_POST_CURRENT_MODULE
# Returns 0 for 'yes', 1 for 'no'. <quit> dos not return.

_post_ask_run()
{
typeset question reply

sf_banner "`_post_description $_POST_CURRENT_MODULE`"

if [ -n "$sf_forceyes" ] ; then
	sf_debug "Forcing answer to 'yes'"
	return 0
fi

question='Execute (<Y>es, [N]o'
_post_has_doc $_POST_CURRENT_MODULE && question="$question, Show <D>oc"
question="$question, <Q>uit) ?"

while true
	do
	printf '%s\n' "$question" >&2 # >&2 needed for flush
	read reply
	[ -z "$reply" ] && reply='n'
	reply=`echo "$reply" | sed 's,^\(.\).*$,\1,' | tr '[:upper:]' '[:lower:]'`
	case "$reply" in
		y)	sf_trace "User replied 'Yes'"
			return 0
			;;
		n)	sf_trace "User replied 'No'"
			return 1
			;;
		d)	sf_trace "User replied 'Show doc'"
			echo "-----------------------------------------------------"
			echo "`_post_get_doc $_POST_CURRENT_MODULE`"
			echo "-----------------------------------------------------"
			echo
			;;
		q)	sf_trace "User replied 'Quit'"
			sf_msg "--<< Aborting postinstall on user's request >>--"
			_post_exit 2
			;;
		*)	sf_warning "Please choose from available options"
			;;
	esac
done
}

#-------------------------
# $1 = module

_post_has_doc()
{
grep "^$1 " $_POST_CACHED_DOC >/dev/null
}

#-------------------------

_post_get_doc()
{
typeset module

module="$1"

grep "^$module " $_POST_CACHED_DOC | sed 's,^[^ ][^ ]* ,,'
}

#-------------------------
# $1: type
# $2: module

_post_msymbol()
{
echo "_smsymb_$1_`echo $2 | sed 's,/,__,g'`"
}

#-------------------------
# Uses $_POST_CURRENT_MODULE

_post_do_run()
{
if [ -n "$sf_noexec" ] ; then
	sf_msg "$_POST_CURRENT_MODULE: Simulating module execution"
	return
fi

`_post_msymbol run $_POST_CURRENT_MODULE`
}

#-------------------------
# $*: list of module names
# Returns : 0 if dependencies are satisfied, <>0 if not

post_require_module()
{
typeset status module

for module
	do
	post_has_run $module && continue

	sf_trace "This action requires this module : $module"
	_post_run_module $module
	status=$?
	if [ $status != 0 ] ; then
		sf_trace "Unsatisfied dependency - Aborting action"
		return $status
	fi
done
return 0
}

#-------------------------
# Uses $_POST_CURRENT_MODULE

_post_can_run()
{
if [ "$_post_force" -lt 2 ] ; then
	if  ! `_post_msymbol can_run $_POST_CURRENT_MODULE` ; then
		sf_trace "$_POST_CURRENT_MODULE: Module cannot run"
		return 1
	fi
else
	sf_trace "$_POST_CURRENT_MODULE: Skipping 'can_run' test (forced)"
fi

return 0
}

#-------------------------
# $1 = module
# Returns :
#	0 : Module has run already
#	!0 : Module has not run

post_has_run()
{
`_post_msymbol has_run $1`
}

#-------------------------
# Uses $_POST_CURRENT_MODULE
# Returns :
#	0: OK
#	1: Invalid environment for this module
#	2: Already run
#	3: User explicitely refused run

_post_will_run()
{
typeset status

sf_debug "Starting will_run($module)"

_post_can_run || return 1

post_has_run $_POST_CURRENT_MODULE
status=$?

if [ $status = 0 ] ; then
	if [ "$_post_force" -lt 1 ] ; then
		sf_trace "$_POST_CURRENT_MODULE: Module has run already"
		return 2
	else
		sf_warning "$_POST_CURRENT_MODULE: Module has run already (forcing)"
	fi
fi

_post_ask_run
if [ $? != 0 ] ; then
	sf_trace "$_POST_CURRENT_MODULE: Module won't run on user's request"
	return 3
fi

sf_trace "$_POST_CURRENT_MODULE: Module will run"
return 0
}

#-------------------------
# Uses $_POST_CURRENT_MODULE
# Called by _post_run_module only

_post_run2()
{
typeset status

_post_will_run
status=$?
[ $status = 2 ] && return 0			# Ran already
[ $status = 0 ] || return $status	# Other reason not to run

_post_do_run
post_has_run $_POST_CURRENT_MODULE && return 0
sf_error "$_POST_CURRENT_MODULE: Errors detected during module execution"
return 1
}

#-------------------------
# Entry point (recursive through 'require_module')
# $1: Module

_post_run_module()
{
typeset rc

saved_module=$_POST_CURRENT_MODULE
export _POST_CURRENT_MODULE=$1

_post_run2
rc=$?

export _POST_CURRENT_MODULE=$saved_module
return $rc
}

#-------------------------

_post_description()
{
# $1 = module

grep "^$1 " $_POST_CACHE_DIR/modules.list | sed 's,^[^ ]* ,,'
}

#-------------------------
# Can be called by a module 'can_run' code with no arg (for current module) or
# internally with a module name arg.

post_module_explicit_run()
{
# $1 = module

[ -z "$_POST_EXPLICIT_MODULES" ] && return 1

module=$1
[ -z "$module" ] && module=$_POST_CURRENT_MODULE
[ -z "$module" ] && return 1

for spec in $_POST_EXPLICIT_MODULES
	do
	[ "$spec" = ALL ] && return 0
	[ "$module" = "$spec" ] && return 0
	echo " $module" | fgrep " $spec/" >/dev/null && return 0
done

return 1
}

#-------------------------
# $* : tags
# Returns 0 if all the provided tags are set

post_tag_isset()
{
for tag
	do
	tag=`sf_db_normalize "$tag"`
	echo " $_POST_TAGS " | fgrep " $tag " >/dev/null || return 1
done

return 0
}

#-------------------------

_post_module_match()
{
# $1: module

[ -z "$_POST_EXPLICIT_MODULES" ] && return 0

post_module_explicit_run $1
}

#-------------------------

_post_cleanup()
{
sf_cleanup

[ -f $_POST_CACHE_DIR/cleanup.sh ] && . $_POST_CACHE_DIR/cleanup.sh
}

#-------------------------
# $1 = return code

_post_exit()
{
typeset rc

rc="$1"
[ -z "$rc" ] && rc=1

_post_cleanup

[ -n "$SF_ERRLOG" ] && \rm -rf $_POST_ERRLOG

exit $rc
}

#---------------

_post_clean_cache()
{
\rm -rf $_POST_CACHE_DIR/* 2>/dev/null
}

#---------------
# Used by build.sh
# Transfer a file from central repo to local cache

_post_sync_file()
{
typeset source fname

for source ; do
	fname=`basename $source`
	\rm -rf "$_POST_CACHE_DIR/$fname"
	if [ -f "$_POST_CFG_BASE/$source" ] ; then
		\cp "$_POST_CFG_BASE/$source" "$_POST_CACHE_DIR"
		chmod 444 "$_POST_CACHE_DIR/$fname"
	fi
done
}

#==============================================================================
