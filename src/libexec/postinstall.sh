#
# Copyright 2010 - Francois Laupretre <francois@tekwire.net>
#
#=============================================================================
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License (LGPL) as
# published by the Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#=============================================================================

#=== When installing from an RPM package, this script is automatically executed.
#=== When installing from a zip/tgz package, this script must be run after the
#=== package file is extracted to /opt/postinstall.
#=============================================================================

if [ ! -f /usr/bin/sysfunc.sh ] ; then
	echo "ERROR: This software requires the sysfunc library (see http://sysfunc.tekwire.net)"
	exit 1
fi

. sysfunc.sh

#---

_base=/opt/postinstall

#--- Create a posix-compatible shell link

_link_source=$_base/libexec/shell

for _s in bash ksh
	do
	for _d in /bin /usr/bin /sbin /usr/sbin /usr/local/bin /usr/local/sbin
		do
		if [ -x $_d/$_s ] ; then
			sf_msg1 "postinstall will use this shell: $_d/$_s"
			sf_check_link $_d/$_s $_link_source
			break
		fi
	done
	[ -x $_link_source ] && break
done

[ -x $_link_source ] || sf_fatal "Cannot find any posix-compatible shell on this host"

#--- Ensure scripts are executable

chmod 755 $_base/bin/* $_base/libexec/*

#--- Create the cache dir

sf_create_dir $_base/cache root 755

#=============================================================================
