#!/bin/bash
# Build TDS debian package

# Install the following depends if build fails
 sudo apt-get -y update
 sudo apt-get -y install zlib1g-dev libssl-dev libsqlite3-dev libmysqlclient-dev imagemagick librmagick-ruby libxml2-dev libxslt1-dev build-essential openssl libreadline6 libreadline6-dev zlib1g libyaml-dev libsqlite3-0 sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison libpq-dev libpq5 libmysql-ruby libmysqlclient-dev libqt4-dev libqtwebkit-dev git nodejs npm yasm libgpac-dev libdirac-dev libgsm1-dev libschroedinger-dev libspeex-dev libvorbis-dev libopenjpeg-dev libdc1394-22-dev libsdl1.2-dev texi2html libfaac-dev libmp3lame-dev libtheora-dev libopencore-amrnb-dev libcurl4-openssl-dev libopencore-amrwb-dev frei0r-plugins-dev libcv-dev libvpx-dev libgavl1 libx264-dev redis-server python-software-properties postgresql libpq-dev


# Variables
CWD=`pwd`
TOOLS="$CWD/tools"
EXTRAS="$CWD/extras"
PACKAGE="$CWD/package"
PACKAGE_NAME="TDS_DEP"
APP="$PACKAGE/opt/caps"
VENDOR="$APP/vendor"

# Update project from github
cd $PACKAGE
git pull origin master
git submodule update
git submodule foreach git pull

# Copy template files
cp $EXTRAS/database.yml.template $APP/config/database.yml.template
cp $EXTRAS/tds.sh $VENDOR/bin/tds
cp $EXTRAS/tds_setup.sh $VENDOR/bin/tds_setup.sh

# Make and install FFMBC

if [[ -f $CWD/tmp ]]; then
	cd FFmbc-0.7-rc7
	make install
else
	mkdir $CWD/tmp
	cd $CWD/tmp

	wget http://ffmbc.googlecode.com/files/FFmbc-0.7-rc7.tar.bz2
	tar -jxvf FFmbc-0.7-rc7.tar.bz2
	cd FFmbc-0.7-rc7
	./configure --enable-gpl --enable-libx264 --enable-nonfree --prefix=$APP/vendor
	make
fi

#chown -R `whoami` $PACKAGE
cd $CWD

mv ./tmp /tmp

dpkg -b $PACKAGE
#mv $PACKAGE.deb $PACKAGE_NAME.deb

mv /tmp/tmp ./tmp

# Cleanup
# rm -rf $PROJECT_DIR/opt/caps/vendor

cd $CWD/tmp/FFmbc-0.7-rc7
make uninstall
rm -rf $CWD/tmp

rm $VENDOR/bin/tds
rm $VENDOR/bin/tds_setup.sh
rm $APP/config/database.yml.template
