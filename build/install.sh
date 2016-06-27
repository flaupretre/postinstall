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

# $INSTALL_ROOT variable can be set by the calling environment and is optional.
# If not set, everything will be installed relative to '/'.

function make_dir
{
[ -d $1 ] || mkdir -p $1
}

#----------

CMD=`basename $0`
cd `dirname $0`/..
BASE_DIR=`/bin/pwd`

INSTALL_TARGET_DIR="$1"
INSTALL_DIR="$INSTALL_ROOT$1"

export BASE_DIR INSTALL_DIR

cd $BASE_DIR

#-- Re-create target tree and copy base files

make_dir $INSTALL_DIR

rm -rf $INSTALL_DIR/*

cp -rp ppc/* $INSTALL_DIR
chmod +x $INSTALL_DIR/*/*

make_dir $INSTALL_ROOT/usr/bin
/bin/rm -rf $INSTALL_ROOT/usr/bin/postinstall
ln -s $INSTALL_TARGET_DIR/bin/postinstall.sh $INSTALL_ROOT/usr/bin/postinstall

$INSTALL_DIR/libexec/set-shell.sh

###############################################################################
