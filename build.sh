#!/bin/bash
# version 2.0

# Single source of truth: VERSION holds <bacula_version>.<build_seed> e.g. 15.20
# Local builds only care about the Bacula version (the part before the last dot);
# the build number bX is computed from git history by the CI workflow.
if [ -f VERSION ]; then
	ver=$(tr -d '[:space:]' < VERSION)
	ver=${ver%.*}
else
	echo "Missing VERSION file"
	exit 1
fi

function db_connector {
	read -ep "Select db connector: 1) postgresql, 2) sqlite3 (q)uit: " -N 1 dbconn
	checker_db
}

function checker_db {
	if [ "$dbconn" == 1 ];then
		database="postgresql"
		build_image
	elif [ "$dbconn" == 2 ];then
		database="sqlite3"
		build_image
	elif [ "$dbconn" == "q" ];then
		exit 0
	else
		echo -e "\nYou should type '1' or '2'"
		db_connector
	fi
}

function set_db {
	case "$1" in
		pgsql|postgresql) database="postgresql" ;;
		sqlite|sqlite3)   database="sqlite3" ;;
		*) echo "Unknown db connector: $1 (use pgsql or sqlite3)"; exit 2 ;;
	esac
}

function build_image {
	echo -e "\nBuilding Bacula $ver ($database) image"
	if [ -f .bacularis_pass ];then
		source .bacularis_pass
		export bacularis_user bacularis_pass
	else
		echo "Can't build without credentials to https://users.bacularis.com/user/register/"
		exit 1
	fi
	DOCKER_BUILDKIT=1 docker build \
		--secret id=bacularis_user,env=bacularis_user \
		--secret id=bacularis_pass,env=bacularis_pass \
		--build-arg DB=$database \
		--build-arg BACULAV=$ver \
		-t bacula-server:$ver-$database \
		-f Dockerfile --force-rm .
}

case "$#" in
	0)
		db_connector
		;;
	1)
		set_db "$1"
		build_image
		;;
	2)
		# legacy form: ./build.sh <version> <db> - version now comes from VERSION
		if [ "$1" != "$ver" ]; then
			echo "Note: requested version '$1' but VERSION file says '$ver' - building $ver"
		fi
		set_db "$2"
		build_image
		;;
	*)
		echo "Illegal number of parameters"
		exit 2
		;;
esac
