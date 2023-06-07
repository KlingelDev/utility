#!/bin/bash
# Depends on rsync, 7z
#
# Compress folders & files and sync archives to another location
#
# https://github.com/Klingel-Dev/utility/README.md
# https://github.com/Klingel-Dev/utility/LICENCE
#

if ! command -v rsync > /dev/null; then
    echo "Depdency: rsync -- This script uses rsync to tranfer files to
          target directory."
    exit 1
fi

if ! command -v 7z > /dev/null; then
    echo "Depdency: 7z -- This script uses 7z for compression of archives."
    exit 1
fi

COMPDIR=.compressed

while getopts ':o:d:c:h' OPTION; do
    case $OPTION in
        d)
            DEST=$OPTARG
            ;;
        o)
            ORIGIN=$OPTARG
            ;;
        c)
            COMPDIR=$OPTARG
            ;;
        \?)
            echo "Invalid option -$OPTION" >&2
            exit 1
            ;;
        *|h)
            echo "usage: $(basename \$0) [-o origin] [-c compressdir] [-h] [-d destination]" >&2
            exit 1
            ;;
        esac
done

if [ -z "$ORIGIN" ] && [ -z "$DEST" ]; then
    echo "Missing origin (-o) and destination (-d)" >&2
    exit 1
fi

if [ ! -d $COMPDIR ]; then
    echo "Creating $COMPDIR"
    mkdir -p $COMPDIR;
fi

# TODO Propagate deletions
for i in $ORIGIN/*
do
    if [ ! -f "$COMPDIR/$i.7z" ]; then
        7z a $COMPDIR/$i.7z $i
    else
        7z u $COMPDIR/$i.7z $i -uq0
    fi
done

for i in $COMPDIR/*
do
    rsync -arptgoD --progress $i $DEST
done

echo "done."
