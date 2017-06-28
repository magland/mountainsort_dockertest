#!/bin/bash

#if [ -z "$1" ]; then
#    echo ""
#    echo "usage:"
#    echo "./compile_components.sh default"
#    echo "./compile_components.sh mountainview"
#    echo "example components: mdachunk mdaconvert mountainprocess mountainsort mountainview mountaincompare prv mda"
#    exit 0
#fi

# verify if we're running Qt4 or Qt5 qmake
QT_VERSION=`qmake -query QT_VERSION`
if [[ "$QT_VERSION" =~ ^4.*$ ]]
then
  echo "You're trying to build MountainLab with Qt4 ($QT_VERSION) but MountainLab only supports Qt5"
  echo "Please make sure qmake from Qt5 installation is first in your PATH."
  
  # try to find a Qt5 install in $HOME or /opt
  if [ -d "/opt/Qt" ]
  then
    ls -1 /opt/Qt/|grep -sqe '^5\.[[:digit:]]$'
    if [[ "$?" == "0" ]]
    then
      echo "It looks like Qt5 installation(s) might be present in /opt/Qt/"
      echo
      exit 1
    fi
  fi
  if [ -d "$HOME/Qt" ]
  then
    ls -1 "$HOME/Qt"|grep -sqe '^5\.[[:digit:]]$'
    if [[ "$?" == "0" ]]
    then
      echo "It looks like Qt5 installation(s) might be present in $HOME/Qt"
      echo
      exit 1
    fi
  fi
  echo "If you don't have Qt5 installed, please go to http://qt.io and download Qt5"
  echo
  exit 1
fi

qmake -recursive

if [[ $1 == "default" ]]; then
eval qmake
elif [ -z "$1" ]; then
eval qmake
else
eval qmake \"COMPONENTS = $@\"
fi

sha1sum_output_before=$(sha1sum mountainprocess/bin/mountainprocess)

make -j 8
EXIT_CODE=$?
if [[ $EXIT_CODE -ne 0 ]]; then
	echo "Problem in compilation."
else
	echo ""
	echo "Compilation successful."

	RES=$(which mountainprocess)
	if [[ -z $RES ]]; then
		echo ""
		echo "******************************************"
		echo "It appears that mountainprocess is not"
		echo "found in your path. Be sure to add"
		echo "mountainlab/bin to your path. See the"
		echo "installation instructions for more"
		echo "information."
		echo "******************************************"
	fi

	sha1sum_output_after=$(sha1sum mountainprocess/bin/mountainprocess)
	if [[ $sha1sum_output_before != $sha1sum_output_after ]]; then
		output=$(bin/mp-daemon-state-summary)
		if [[ $output == "Daemon is running"* ]]; then
			echo ""
			echo "******************************************"
			echo "It appears a processing daemon is running"
			echo "and the mountainprocess binary has changed."
			echo "You may want to restart the daemon using:"
			echo "mp-daemon-restart"
			echo "******************************************"
		fi
	fi
fi
