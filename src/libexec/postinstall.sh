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

. sysfunc
sf_loaded 2>/dev/null
if [ $? != 0 ] ; then
	echo "ERROR: This software requires the sysfunc library (see http://sysfunc.tekwire.net)"
	exit 1
fi

#--- Ensure scripts are executable

chmod 755 %INSTALL_DIR%/bin/* %INSTALL_DIR%/libexec/*

#--- Create the cache dir

sf_create_dir %INSTALL_DIR%/cache root 755

#--- Create a posix-compatible shell link as %INSTALL_DIR%/shell

. %INSTALL_DIR%/libexec/set-shell.sh

#=============================================================================
