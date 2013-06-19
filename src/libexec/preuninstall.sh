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

#=== When uninstalling using RPM, this script is automatically executed.
#=== When uninstalling manually, theis script must be executed before
#=== the /opt/postinstall file tree is deleted
#=============================================================================

# When upgrading package, do nothing (remember that, during an upgrade,
# uninstall of old package is done AFTER installation of new).
# When uninstalling, preun script receives '0' as cmd line arg. When upgrading,
# it receives '1'.

[ -n "$1" -a "$1" != 0 ] && exit 0

#---

if [ ! -f /usr/bin/sysfunc.sh ] ; then
	echo "ERROR: This software requires the sysfunc library (see http://sysfunc.tekwire.net)"
	exit 1
fi

. sysfunc.sh

#---

_base=/opt/postinstall

#--- Remove the shell link

_link_source=$_base/libexec/shell

sf_delete $_link_source

#--- Remove cache dir

sf_delete $_base/cache

#=============================================================================
