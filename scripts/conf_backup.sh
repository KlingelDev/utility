#!/bin/bash
# Depends on rsync, perl
#
# backup conf files provided in cb.conf to destination
#
# https://github.com/Klingel-Dev/utility/README.md
# https://github.com/Klingel-Dev/utility/LICENCE
#
#-x

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
            echo "usage: $(basename \$0) [-o origin] [-c config] [-h] [-d destination]" >&2
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
    # TODO make it an option to work without flags
    # TODO make folder compression possible
    # TODO make encryption possible
    if [[ $(printf "$l" | perl -ne 'print 1 if /^((u|h))\s.*$/') == '1' ]]; then
    opt=( $(printf "$l" | perl -pe 's!^\s*(\w+)(.*)\/{1}\.*([\w\.\-]+)$!$1!g') # Flag
          $(printf "$l" | perl -pe 's!^\s*(\w+)(.*)\/{1}\.*([\w\.\-]+)$!$2!g') # Path
          $(printf "$l" | perl -pe 's!^\s*(\w+)(.*)\/{1}([\w\.\-]+)$!$3!g') # Folder name
          $(printf "$l" | perl -pe 's!^\s*\w+\s([\/~\w\.\-]+)$!$1!g') ) # Full Path

        rsync_opt="-arpgoD --no-times --checksum"
        o="${opt[3]/#~/$HOME}"

        flags=${opt[0]}
        t=${opt[2]}
        d="${opt[1]/#~/$HOME}"
        n=$(echo $d | sed "s=$ORIGIN\/*==g")
        if [[ "$n" != "" ]]; then
            n="$n/"
        fi

        # Remove leading dots, unhide
        if [[ $(printf "$flags" | perl -ne 'print 1 if /u/g') == '1' ]]; then
            n=$(echo $n | sed "s=^\.==g")
            t=$(echo $t | sed "s=^\.==g")
        fi

        if [[ $KEEP_DEPTH == 1 ]]; then
            if [ ! -d "$DEST/$n" ]; then
                echo "Creating $DEST/$n"
                mkdir -p $DEST/$n;
            fi
            fdest="$DEST/$n$t"
        else
            fdest="$DEST/$t"
        fi

        echo "rsync $rsync_opt $o $fdest"
        rsync $rsync_opt $o $fdest

    fi
done

# TODO make the whole process reverseable

echo "done."
exit 0
