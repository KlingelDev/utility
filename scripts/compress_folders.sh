#!/bin/bash
# Depends on rsync, 7z
#
# Compress folders & files and sync archives to another location
#
# https://github.com/Klingel-Dev/utility/README.md
# https://github.com/Klingel-Dev/utility/LICENCE
#
#set -x

if ! command -v rsync > /dev/null; then
    echo "Depdency: rsync -- This script uses rsync to tranfer files to
          target directory."
    exit 1
fi

if ! command -v 7z > /dev/null; then
    echo "Depdency: 7z -- This script uses 7z for compression of archives."
    exit 1
fi

COMPDIR=".compressed"
PROPOGATEDEL=0

while getopts ':o:d:c:hp' OPTION; do
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
        p)
            PROPOGATEDEL=1
            ;;
        \?)
            echo "Invalid option -$OPTION" >&2
            exit 1
            ;;
        *|h)
            echo "usage: $(basename \$0) [-o origin] [-c compressdir] [-h] [-p] [-d destination]" >&2
            exit 1
            ;;
    esac
done

# TODO remove last slash

COMPDIR=$ORIGIN/$COMPDIR

if [ -z "$ORIGIN" ] && [ -z "$DEST" ]; then
    echo "Missing origin (-o) and destination (-d)" >&2
    exit 1
fi

if [ ! -d $COMPDIR ]; then
    echo "Creating $COMPDIR"
    mkdir -p $COMPDIR;
fi

# TODO make this a function
# Get file lists, deal with spaces
# Origin folders/files
readarray -t o_files < <(find $ORIGIN -maxdepth 1 -mindepth 1 -not -path "*/.*" -printf '%f\n')

# Dest file list
readarray -t d_files < <(find $DEST -maxdepth 1 -mindepth 1 -not -path "*/.*" -printf '%f\n')

# NOTE appears not to be needed
# escape file names
# for i in ${!o_files[@]}
# do
#     o_files[$i]=$(printf '%s' "${o_files[$i]}" | sed -E 's/[^a-zA-Z0-9,._+@%/-]/\\&/g;')
# done
# for i in ${!d_files[@]}
# do
#     d_files[$i]="$(printf '%s' "${d_files[$i]}" | sed -E 's/[^a-zA-Z0-9,._+@%/-]/\\&/g;')"
# done

# Propagate deletions
if [ $PROPOGATEDEL == 1 ]; then
    # compare DEST and ORIGIN, remove everything that is not in ORIGIN anymore
    for i in ${!d_files[@]}
    do
        found=0
        for y in ${!o_files[@]}
        do
            if [[ "${d_files[$i]}" == "${o_files[$y]}.7z" ]]; then
                found=1
                break
            fi
        done
        if [[ $found == 1 ]]; then
            continue
        else
            # TODO make this work for remote dest
            if [ -f "$COMPDIR/${d_files[$i]}" ]; then
                rm "$COMPDIR/${d_files[$i]}"
            fi
            rm "$DEST/${d_files[$i]}"
        fi
    done
fi

for f in "${o_files[@]}"
do
    if [ ! -f "$COMPDIR/$f.7z" ]; then
        7z a "$COMPDIR/$f.7z" "$ORIGIN/$f" | grep "ing archive"
    else
        7z u "$COMPDIR/$f.7z" "$ORIGIN/$f" -uq0 | grep "ing archive"
    fi
done

for z in "${o_files[@]}"
do
    rsync -arptgoD --progress --checksum "$COMPDIR/$z.7z" $DEST
done

echo "done."
exit 0
