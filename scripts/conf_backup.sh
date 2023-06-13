#!/bin/bash
# Depends on rsync
#
# backup conf files provided in cb.conf to destination
#
# https://github.com/Klingel-Dev/utility/README.md
# https://github.com/Klingel-Dev/utility/LICENCE
#

if ! command -v rsync > /dev/null; then
    echo "Depdency: rsync -- This script uses rsync to tranfer files to
          target directory."
    exit 1
fi

CONFFILE=~/.conf_backup.conf
ORIGIN=$HOME

while getopts ':c:d:o:' OPTION; do
    case $OPTION in
        o)
            ORIGIN=$OPTARG
            ;;
        d)
            DEST=$OPTARG
            ;;
        c)
            CONFFILE=$OPTARG
            ;;
        \?)
            echo "Invalid option -$OPTION" >&2
            exit 1
            ;;
        *|h)
            echo "usage: $(basename \$0) [-c config] [-h] [-d destination]" >&2
            exit 1
            ;;
    esac
done


DEST=$(printf "$DEST" | perl -pe 's!\/$!!')
KEEP_DEPTH=0

readarray -t CONF < $CONFFILE
# TODO Deal with spaces
# Look for options
for l in "${CONF[@]}"
do
    if [[ $(printf "$l" | perl -ne 'print 1 if /^((origin|dest|opt))\s.*$/') == '1' ]]; then
        opt=( $(printf "$l" | perl -pe 's!^(origin|dest|opt)\s.*!$1!g')
              $(printf "$l" | perl -pe 's!^\w*\s([\w\~\.\/-]+)!$1!g') )

        echo ${opt[*]}
        if [[ "${opt[0]}" == "origin" ]]; then
            ORIGIN="${opt[1]/#~/$HOME}"

        elif [[ "${opt[0]}" == "dest" ]]; then
            DEST="${opt[1]/#~/$HOME}"

        elif [[ "${opt[0]}" == "opt" ]]; then
            if [[ "${opt[1]}" == "keep_depth" ]]; then
                KEEP_DEPTH=1
            fi
        fi
    fi
done

if [ -z "$DEST" ]; then
    echo "Missing destination (-d)" >&2
    exit 1
fi

echo "DEST", $DEST
echo "ORIGIN", $ORIGIN
echo "KEEP_DEPTH", $KEEP_DEPTH

for l in "${CONF[@]}"
do
    # TODO make folder compression possible
    if [[ $(printf "$l" | perl -ne 'print 1 if /^((u|h))\s.*$/') == '1' ]]; then
        opt=( $(printf "$l" | perl -pe 's!^(u|h)\s.*!$1!g')
              $(printf "$l" | perl -pe 's!^\w*\s([\w\~\.\/-]+)$!$1!g')
              $(printf "$l" | perl -pe 's!.*\/\.*([\w\.-]+)$!$1!g')
              $(printf "$l" | perl -pe 's!^.*\/([\w\.-]+)$!$1!g') )

        echo ${opt[*]}
        rsync_opt="-arpgoD --no-times --progress --checksum"
        o="${opt[1]/#~/$HOME}"
        echo $o
        if [ ${opt[0]} == "u" ]; then
            echo One
            echo "rsync $rsync_opt $o $DEST/${opt[2]}"
            #rsync $rsync_opt $o $DEST/${opt[2]}
        else
            echo Two
            echo "rsync $rsync_opt $o $DEST/${opt[3]}"
            #rsync $rsync_opt $o $DEST/${opt[2]}
        fi
    fi
done

