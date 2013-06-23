#!/usr/local/bin/bash

echo "If you're ready to install everything, hit Enter."
read DUMMY

echo "Checking everything's committed in git..."
# check everything's committed
DIFFS=$(git status --porcelain | grep '^ M' | wc -l )
if [[ $DIFFS -ne 0 ]]; then
	echo There are uncommitted changes - please check those in first
	exit 1
fi

inst_all_in() {
	DEST=$2
	SRC=$1
	for i in `git ls-files $SRC`; do
		install -d -v $DEST/`dirname $i`
		install -v $i $DEST/`dirname $i`
	done
}

error_out() {
	echo $*
	exit 1 
}
test -d "$1" || error_out "No destination directory provided"
DEST=$1

echo "Installing to destination directory $DEST"
inst_all_in scripts $DEST
inst_all_in conf $DEST
inst_all_in MP3S $DEST
inst_all_in templates $DEST
inst_all_in tests/mocks $DEST
echo DONE
