#!/bin/bash
# version 1.1

function db_connector {
	read -ep "Select db connector: 1) postgresql, 2) sqlite3 (q)uit: " -N 1 dbconn
	checker_db
}

function checker_db {
	if [ $dbconn == 1 ];then
		database="postgresql"
		ver="11"
		build_image
	elif [ $dbconn == 2 ];then
		database="sqlite3"
		ver="11"
		build_image
	elif [ $dbconn == "q" ];then
		exit 0
	else
		echo -e "\nYou should type '1' or '2'"
		db_connector
	fi
}

function build_image {
	echo -e "\nBuilding image"
	docker build --build-arg DB=$database -t bacula-server:$ver-$database -f Dockerfile-$ver --force-rm .
}

if [ "$#" == "0" ]; then
	db_connector
elif [ "$#" != "2" ]; then
	echo "Illegal number of parameters"
	exit 2
elif [ "$#" == "2" ]; then
	if [ "$2" == "pgsql" ]; then
		if [ $1 == "11" ]; then
			database="postgresql"
			ver="11"
			build_image
		fi
	elif [ "$2" == "mysql" ]; then
		if [ $1 == "11" ]; then
			echo "There is no version 11 with mysql"
			exit 2
		fi
	elif [ "$2" == "sqlite" ] || [ "$2" == "sqlite3" ]; then
		if [ $1 == "11" ]; then
			database="sqlite3"
			ver="11"
			build_image
		fi
	fi
else
	echo "Unknown error"
	exit 2
fi

