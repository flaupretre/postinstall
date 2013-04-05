#
#-------------------------------------------------------------------------------

# Remove useless and potentially conflicting variables

unset LANG LC_MONETARY LC_TIME LC_MESSAGES LC_CTYPE LC_COLLATE LC_NUMERIC || :

#--- Base

export _POST_BASE=/opt/postinstall

#--- Internal/cached

export _POST_BIN_DIR=$_POST_BASE/bin
export _POST_CACHE_DIR=$_POST_BASE/cache
export _POST_LIBEXEC_DIR=$_POST_BASE/libexec
export _POST_CACHED_MODULES_SH=$_POST_CACHE_DIR/modules.sh
export _POST_CACHED_MODULES_LIST=$_POST_CACHE_DIR/modules.list
export _POST_CACHED_DOC=$_POST_CACHE_DIR/modules.doc

#--- External dirs/files

export _POST_LOGFILE=/var/log/postinstall.log
export _POST_TMP_DIR=/tmp
export SF_ERRLOG=$_POST_TMP_DIR/.postinstall_$$.err

#--- Other

export POST_CFG_KEY=postinstall:config/base

#-------------------------------------------------------------------------------
