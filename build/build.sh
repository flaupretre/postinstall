#
# Copyright 2009-2014 - Francois Laupretre <francois@tekwire.net>
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


CMD=`basename $0`
cd `dirname $0`/..
BASE_DIR=`/bin/pwd`

SOFTWARE_VERSION="$1"
INSTALL_DIR="$2"

export BASE_DIR SOFTWARE_VERSION INSTALL_DIR

#==== MAIN ====

cd $BASE_DIR/src

mkdir -p ../ppc/bin ../ppc/libexec

for i in `find . -type f` ; do
	tdir=../ppc/`dirname $i`
	[ -d $tdir ] || mkdir -p $tdir
	target=$tdir/`basename $i`
	sed -e "s,%INSTALL_DIR%,$INSTALL_DIR,g" \
		-e "s,%SOFTWARE_VERSION%,$SOFTWARE_VERSION,g" <$i >$target
	chmod +x $target
done
