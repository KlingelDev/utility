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

while getopts ':c:d:' OPTION; do
    case $OPTION in
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

readarray -t CONF < $CONFFILE
for l in "${CONF[@]}"
do
    opt=( $(printf "$l" | perl -pe 's!^([uh]+) .*!$1!g'),
          $(printf "$l" | perl -pe 's!^\w*\s([\w\~\.\/]+)$!$1!g'),
          $(printf "$l" | perl -pe 's!^.*\/\.*([\w\.]+)$!$1!g') )

    echo ${opt[*]}
    # if [ ${l[0]} == "u" ]; then
    #     d=( $(sed '/\.*([\w\.]+)$//g$' <<< ${l[1]}) )
    #     #rsync -arptgoD --progress --checksum  $DEST
    # fi
done

