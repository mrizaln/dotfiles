#!/bin/bash

### alternative names for the options
declare -A author
author=( ["choco"]="ちょこ" ["fubuki"]="フブキ" ["ayame"]="あやめ" ["lamy"]="ラミィ" ["noel"]="ノエル" ["nana"]="なな" ["shion"]="シオン" ["okayu"]="おかゆ" ["mayo"]="まよ" ["rushia"]="るしあ" ["roboco"]="ロボ子" ["mel"]="メル" ["mio"]="ミオ" ["korone"]="ころね" ["fluor"]="フローラ")
playlist="/tmp/playlist"

case $1 in
    '')
    printf "\033[s"
    echo -e '--------------- whose asmr would you like to hear? --------------- \n'
    echo 'options   : choco, fubuki, ayame, lamy, noel, nana, shion, okayu, mayo, rushia, roboco, mel, mio, korone, all'
    echo 'note      : add some phrase or word to specify your playlist more'
    echo -e 'syntax    : [options ...] -p=<phrase|word> -a=<addditional option> \n'
    read -p "your input: " arguments # this is a string, can be used as list separated by spaces

    for i in {1..7}; do
#        printf "\033[u"
        printf "\033[1A"
        printf "\033[K"
    done
    ;;

    *)
    arguments=${@} # this is a string, can be used as list separated by spaces
    ;;
esac

##### temporary section
if [ `echo $arguments | cut -d\  -f1` == iruiru ]; then
    cd /home/mrizaln/others/iru_fluor
    read -p 'mimikaki? neru? massage? shinon? ' res
    printf "\033[1A"; printf "\033[K"

    if [ $res == mimikaki ]; then res=耳かき
    elif [ $res == shinon ]; then res=心音
    elif [ $res == neru ]; then res=寝
    elif [ $res == massage ]; then res=マッサージ
    fi

    grep $res iru_fluor_links.txt | mpv --playlist=- --shuffle --no-video
    exit 0
fi
##### end of temporary section

for arg in $arguments; do
    if [[ $arg =~ ^\-p.* ]]; then
        phrase=${arg#"-p="}
    elif [[ $arg =~ ^\-a.* ]]; then
        additional=${arg#"-a="}
    else
        options+=("$arg") # this is a list
    fi
done

cd /home/mrizaln/Music/asmr
if [ `echo $arguments | cut -d\  -f1` == all ]; then
    find $PWD -type f | mpv --playlist=- --no-video --$additional
    exit 0
fi
for opt in ${options[@]}; do
    if [ "${author[$opt]}" == "" ]; then author["$opt"]=$opt; fi
    find $PWD -type f | grep -iE "$opt|${author[$opt]}" | grep -i "$phrase" >> $playlist
done

[ `cat $playlist | wc -l` -eq 0 ] && echo 'no matching asmr found' && exit 0

mpv --playlist=$playlist --no-video --$additional
rm $playlist
