#!/bin/bash

#------------------------------------------------------------------------
# - made by Peter Svihra, FNSPE CTU in Prague
# - the script needs at least 1 parameter (nCores)
# - first parameter is number of cores for faster execution
# - second parameter is direct link to download the root file with .tar.gz
# extension (automatically 6.08.06, possible any version supporting cmake)
# - third parameter is shell type used (automatically bash, possible zsh)
#------------------------------------------------------------------------

if [ $# -eq 0 ]; then
    echo "#########################################################################################";
    echo "Add number of the used cores, direct link to download and shell type (automatically bash)";
    echo "bash installRoot.sh nCores directWebLink shellType";
    echo "#########################################################################################";
    exit
fi

if [ $# -eq 2 ]; then
    echo "Will download file from $2";
    WEB=$2;
else
    WEB=https://root.cern.ch/download/root_v6.08.06.source.tar.gz;
fi

NAME=$WEB;
NAME=${NAME/https\:\/\/root\.cern\.ch\/download\//};
NAME=${NAME/\.source\.tar\.gz/};

if [ $# -eq 3 ]; then
    echo "#########################################################################################";
    echo "Using $3 shell";
    echo "#########################################################################################";
    SHELL=$3;
else
    SHELL=bash;
fi

FILE=~/Downloads/$NAME.tar.gz;

if ! wget --show-progress --output-document=$FILE $WEB ; then
    echo "#########################################################################################";
    echo "Could not download the file $WEB";
    echo "#########################################################################################";
    exit;
else
    echo "#########################################################################################";
    echo "File successfuly downloaded";
    echo "#########################################################################################";
fi

if [ $# -eq 0 ]; then
    echo "#########################################################################################";
    echo "Using only one core";
    echo "#########################################################################################";
    CORES=1;
else
    if [[ $1 =~ ^-?[0-9]+$ ]]; then
        CORES=$1;
    else
		echo "#########################################################################################";
		echo "Not valid cores count, using only one";
		echo "#########################################################################################";
		CORES=1;
    fi
fi

sudo echo ;
sudo apt-get --ignore-missing --yes --force-yes install qtcreator git dpkg-dev gcc g++ make cmake binutils libx11-dev libxpm-dev libxft-dev libxext-dev libqt4-dev python python-dev;

if [ ! -d /opt/$NAME/root-build ]; then

    if sudo mkdir -p /opt/$NAME/root-build; then
        echo "#########################################################################################";
		echo "build dir - created";
        echo "#########################################################################################";
	else
        echo "#########################################################################################";
		echo "build dir - creation failed";
		echo "#########################################################################################";
		exit;
    fi
else
    echo "#########################################################################################";
    echo "build dir - already exists";
    echo "#########################################################################################";
fi


if [ ! -d /opt/$NAME/source ]; then
    if sudo mkdir -p /opt/$NAME/source; then
		echo "#########################################################################################";
        echo "source dir - created";
        echo "#########################################################################################";
	else
		echo "#########################################################################################";
        echo "source dir - creation failed";
		echo "#########################################################################################";
        exit;
    fi
else
		echo "#########################################################################################";
        echo "source dir - already exists";
		echo "#########################################################################################";
fi

if sudo tar -C /opt/$NAME/source --strip-components 1 -zxf $FILE; then
    echo "#########################################################################################";
    echo "unpack - successful";
    echo "#########################################################################################";
else
    echo "#########################################################################################";
    echo "unpack - failed";
    echo "#########################################################################################";
    exit;
fi

SOURCE=/opt/$NAME/source
echo "#########################################################################################";
echo "source dir - "$SOURCE;
echo "#########################################################################################";

cd /opt/$NAME/root-build
echo "#########################################################################################";
echo "build dir - changed directory";
echo "#########################################################################################";

echo "#########################################################################################";
echo "running cmake";
echo "#########################################################################################";
sudo cmake -DCMAKE_INSTALL_PREFIX=/opt/$NAME/root-install -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -DCMAKE_LINKER=ld -Dall=ON $SOURCE

sudo make -j$CORES
sudo make install

cd /usr/local/bin
sudo ln -sv /opt/$NAME/root-install/bin/*

#Change the lines if using different shell than bash (such as zsh)
if [ $SHELL == "bash" ]; then 
echo "#########################################################################################";
echo "Using bash";
echo "#########################################################################################";
cat <<EOT >> ~/.bashrc
#
#ROOT sourcing
source /opt/$NAME/root-install/bin/thisroot.sh
EOT
elif [ $SHELL == "zsh" ]; then
echo "Using zsh";
cat <<EOT >> ~/.zshrc
#
#ROOT sourcing
cd /opt/$NAME/root-install
source bin/thisroot.sh
popd > /dev/null
EOT
fi
