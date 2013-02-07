#!/bin/bash
# TDS Master script

DESC="TDS Server"
USER_NAME="tds_deploy"
USER=`whoami`
BIN_DIR="/opt/caps/vendor/bin"


if [[ "$USER" != "root" ]]; then
	echo "$0 requires root to run.";
	exit 1;
fi

case "$1" in
	start)

		if [ -f /opt/caps/config/database.yml ]
		then
			echo -n "Starting $DESC: "
	        start redis-server
	        start juggernaut
	        start sidekiq
	        start nginx
			curl 127.0.0.1:80 > /dev/null 2>&1 # KICKSTART
		else
			echo -n "Run $0 configure before starting the server"
		fi
	        ;;

	stop)
	        echo -n "Stopping $DESC: "
			stop redis-server
	        stop juggernaut
	        stop sidekiq
	        stop nginx
	        ;;

	restart|force-reload)
	        echo -n "Restarting $DESC: "
	        $0 stop
	        $0 start
	        ;;

	reload)
	        echo -n "Reloading $DESC configuration: "
	        # TODO
	        ;;
	configure|config|setup)
			sudo -u $USER_NAME $BIN_DIR/tds_setup.sh
			;;
esac
