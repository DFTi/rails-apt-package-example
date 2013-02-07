#!/bin/bash

# Helper function
function get_variable
{	
	if [ -z "$1" ]; then
		exit "$0 requires one argument"
	fi

	local MESSAGE=$1
	local CONFIRM=""
	local RESULT=""

	read -p "$MESSAGE:" RESULT
	read -p "You entered: $RESULT; Is this correct [y/n]:" CONFIRM
	if [ "$CONFIRM" = "y" ]; then
		echo "$RESULT"
	else
		get_variable "$MESSAGE"
	fi

}

# Setup

VERSION="1.2.0"

SERVICE_NAME="tds"
APP_DIR="/opt/caps"
APP_DATABASE="$APP_DIR/config/database.yml"
APP_DATABASE_TEMPLATE="$APP_DATABASE.template"

clear

echo "TDS Setup Version $VERSION"
echo "This script will assist in setting up a TDS server instance."

echo ""

echo "TDS Database setup:"

PG_HOST=$(get_variable "Enter Postgres Database hostname")
#echo ""
#PG_PORT=$(get_variable "Enter Postgres Database port")
echo ""
PG_DBNAME=$(get_variable "Enter Postgres Database name")
echo ""
PG_USER=$(get_variable "Enter Postgres Database username")
echo ""
PG_PASS=$(get_variable "Enter Postgres Database password")

# Generate database.yml
sed -e "s/PG_HOST/$PG_HOST/" -e "s/PG_DBNAME/$PG_DBNAME/" -e "s/PG_USER/$PG_USER/"  -e "s/PG_PASS/$PG_PASS/"  $APP_DATABASE_TEMPLATE > $APP_DATABASE

echo ""
echo -e "Generated database.yml\n"
echo -e `cat $APP_DATABASE`

# Congfigure rails app
cd $APP_DIR

echo ""
echo "Creating Database"
RAILS_ENV=production bundle exec rake db:create

echo ""
echo "Loading Database Schema"
RAILS_ENV=production bundle exec rake db:schema:load

echo ""
echo "Seeding Database"
RAILS_ENV=production bundle exec rake db:seed

echo ""
echo "Compiling Assets"
rm -rf $APP_DIR/public/assets
RAILS_ENV=production bundle exec rake assets:precompile
