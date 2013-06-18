#!/opt/postinstall/libexec/shell

exec >/dev/console 2>&1

#-- Load sysfunc

. sysfunc.sh

#-- Run bootstrap

postinstall -v -y -t _BOOTSTRAP

#-- Remove bootstrap hook

postinstall -u

#-- End screen

echo
echo "Type : <h>+<Enter> to halt the host"
echo "       <l>+<Enter> to log in"
echo "           <Enter> to reboot"
read a </dev/console

case "$a" in
	[hH]*)
		echo "=================== Halting host ==========================="
		sf_shutdown
		;;
	[lL]*)
		# Does nothing except disabling reboot
		;;
	*)
		echo "=================== Rebooting host ==========================="
		sf_reboot
		;;
esac
