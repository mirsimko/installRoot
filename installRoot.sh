#!/bin/sh

#------------------------------------------------------------------------
# - made by Peter Svihra, FNSPE CTU in Prague
# - c parameter is number of cores for faster execution
# - w parameter is direct link to download the root file with .tar.gz
# extension (automatically 6.08.06, possible any version supporting cmake)
# - s parameter is shell type used (automatically bash, possible zsh)
#------------------------------------------------------------------------

CORES=1
WEB=https://root.cern.ch/download/root_v6.08.06.source.tar.gz
SHELL=bash

while getopts ":hc:w:s:" opt; do
    case "${opt}" in
        h) echo "./installRoot.sh -c nCores -w directWebLink -s shellType";;
        c) CORES=${OPTARG};;
        w) WEB=${OPTARG};;
        s) SHELL=${OPTARG};;
        \?) echo "Invalid option: -$OPTARG";;
        :) echo "Option -$OPTARG requires an argument."; exit 1;;
    esac
done

echo "#########################################################################################"
echo "Downloading file from: $WEB"
echo "Using shell: $SHELL"
echo "Number of cores: $CORES"

NAME=$WEB;
NAME=${NAME/https\:\/\/root\.cern\.ch\/download\//};
NAME=${NAME/\.source\.tar\.gz/};
FILE=~/Downloads/$NAME.tar.gz;

if [ -f $FILE ]; then
    echo "#########################################################################################";
    echo "$FILE already exists -> skipping download"
else
    if ! wget --show-progress --output-document=$FILE $WEB ; then
        echo "#########################################################################################";
        echo "Could not download the file $WEB";
        exit;
    else
      	echo "#########################################################################################";
      	echo "File successfuly downloaded";
    fi
fi

if [[ $CORES =~ ^-?[0-9]+$ ]]; then
    CORES=$1;
else
  	echo "#########################################################################################";
  	echo "Not valid cores count, using only one";
  	CORES=1;
fi

sudo echo ;
sudo apt-get --ignore-missing --yes --allow install qtcreator git dpkg-dev gcc g++ make cmake binutils libx11-dev libxpm-dev libxft-dev libxext-dev libqt4-dev python python-dev lzma-dev libgl2ps-dev libxml2-dev openssl;

if [ ! -d /opt/$NAME/root-build ]; then

    if sudo mkdir -p /opt/$NAME/root-build; then
        echo "#########################################################################################";
        echo "build dir - created";
    else
        echo "#########################################################################################";
	      echo "build dir - creation failed";
	      exit;
    fi
else
    echo "#########################################################################################";
    echo "build dir - already exists";
fi


if [ ! -d /opt/$NAME/source ]; then
    if sudo mkdir -p /opt/$NAME/source; then
		    echo "#########################################################################################";
        echo "source dir - created";
    else
    		echo "#########################################################################################";
        echo "source dir - creation failed";
        exit;
    fi
else
		echo "#########################################################################################";
    echo "source dir - already exists";
fi

if sudo tar -C /opt/$NAME/source --strip-components 1 -zxf $FILE; then
    echo "#########################################################################################";
    echo "unpack - successful";
else
    echo "#########################################################################################";
    echo "unpack - failed";
    exit;
fi

SOURCE=/opt/$NAME/source
echo "#########################################################################################";
echo "source dir - "$SOURCE;

cd /opt/$NAME/root-build
echo "#########################################################################################";
echo "build dir - changed directory";

echo "#########################################################################################";
echo "running cmake";
sudo cmake -DCMAKE_INSTALL_PREFIX=/opt/$NAME/root-install -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -DCMAKE_LINKER=ld -Dall=ON $SOURCE

sudo make -j$CORES
sudo make install

cd /usr/local/bin
sudo ln -sv /opt/$NAME/root-install/bin/*

#Change the lines if using different shell than bash (such as zsh)
if [ $SHELL == "bash" ]; then
echo "#########################################################################################";
echo "Using bash";
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
