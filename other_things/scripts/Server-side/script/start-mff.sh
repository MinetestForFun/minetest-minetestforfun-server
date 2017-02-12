#!/bin/bash

DEBUG='/home/vincent/jeux/mff/log/debug-mff.txt'
MOREDEBUG='/home/vincent/jeux/mff/log/moredebug-mff.txt'

cd /home/vincent/jeux/mff

while true
	do
	sleep 5

	echo "----------------------" >>$MOREDEBUG
	echo "Server restarted at "`date` >>$MOREDEBUG
	echo "----------------------" >>$MOREDEBUG

	echo "0" >/tmp/players_c.txt

	/home/vincent/jeux/mff/bin/minetestserver \
		--world /home/vincent/jeux/mff/worlds/minetestforfun/ \
		--config /home/vincent/jeux/mff/minetest.conf \
		--gameid minetestforfun_game \
		--port 30002 \
#		--logfile $DEBUG

	sleep 25
done &>> $MOREDEBUG

