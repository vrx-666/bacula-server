#!/bin/bash
# version 1.0

function bacula_ver {
	read -ep "Select bacula version: 1) Bacula11, 2) Bacula9.6 (Type 1 or 2): " -N 1 bversion
	checker_ver
}

function db_connector {
	read -ep "Select db connector: 1) postgresql, 2) mysql, 3) sqlite3 : " -N 1 dbconn
	checker_db
}

function checker_db {
	if [ $dbconn == 1 ];then
		database="postgresql"
		bacula_ver
	elif [ $dbconn == 2 ];then
		database="mysql"
		ver="9.6"
		build_image
	elif [ $dbconn == 3 ];then
		database="sqlite3"
		bacula_ver
	else
		echo -e "\nYou should type '1' or '2' or '3'"
		db_connector
	fi
}

function checker_ver {
	if [ $bversion == 1 ];then
		ver="11"
		build_image
	elif [ $bversion == 2 ];then
		ver="9.6"
		if [ $dbconn == 1 ];then
			database="pgsql"
		fi
		build_image
	else
		echo -e "\nYou should type '1' or '2'"
		bacula_ver
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
		elif [ $1 == "9.6" ]; then
			database="pgsql"
			ver="9.6"
			build_image
		fi
	elif [ "$2" == "mysql" ]; then
		if [ $1 == "11" ]; then
			echo "There is no version 11 with mysql"
			exit 2
		elif [ $1 == "9.6" ]; then
			database="mysql"
			ver="9.6"
			build_image
		fi
	elif [ "$2" == "sqlite" ] || [ "$2" == "sqlite3" ]; then
		if [ $1 == "11" ]; then
			database="sqlite3"
			ver="11"
			build_image
		elif [ $1 == "9.6" ]; then
			database="sqlite3"
			ver="9.6"
			build_image
		fi
	fi
else
	echo "Unknown error"
	exit 2
fi

