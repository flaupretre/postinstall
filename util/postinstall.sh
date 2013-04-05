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

. sysfunc.sh

# Create a posix-compatible shell link

link_source=/opt/$PRODUCT/libexec/shell

\rm -rf $link_source

for s in bash ksh
	do
	for d in /bin /usr/bin /sbin /usr/sbin /usr/local/bin /usr/local/sbin
		do
		if [ -x $d/$s ] ; then
			sf_msg "Using this shell: $d/$s"
			ln -s $d/$s $link_source
			break
		fi
	done
	[ -x $link_source ] && break
done

if [ ! -x $link_source ] &&	sf_fatal "Cannot find any posix-compatible shell on this host"
