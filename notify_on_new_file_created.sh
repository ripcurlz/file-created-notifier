#!/bin/bash


function help {

        printf "ERROR! you have to use this script like:\n" 
        printf "bash notify_on_new_file_created.sh -d <absolute path to dir to be watched> -t <minimum time in between notifications in seconds>\n"
        printf "will exit now...\n"

        exit 1
}


if [ "$1" != "-d" ]; then
        help;
fi

if [ "$3" != "-t" ]; then
        help;
fi

DIR_TO_WATCH="${2}"
MINIMUM_TIME_IN_BETWEEN_NOTIFICATIONS="${4}"

USER_KEY=$(jq -r .pushover_user_key conf.json)
APP_TOKEN=$(jq -r .pushover_token conf.json)

first_time_called=0
date_last_time_called=0

printf "$(date): Now starting...\n"

while read directory file
do      
        # get the size of the created file in bytes
        size_of_file=`du -b $directory$file | cut -f1`
        type_of_file=`file $directory$file`
        # only notify if the file size is bigger than 0!        
        if [ "$size_of_file" -ne "0" ]; then
                message="$(date): New file "$type_of_file" with a size of "$size_of_file" bytes detected"
                printf "$message\n"                
                # do not check the minimum time for the first time this script is called                
                if [ ! $first_time_called ]; then                        
                        printf "$(date): Now trying to notify...\n"
                        curl --form-string "token=${APP_TOKEN}" --form-string "user=${USER_KEY}" \
                        --form-string "message=$message" https://api.pushover.net/1/messages.json
                        first_time_called=1
                        date_last_time_called=$(date +%s)
                        printf "\n$(date): Resultcode of curl command was: $?\n"
                else
                        current_date=$(date +%s)
                        if (( $current_date - $date_last_time_called > $MINIMUM_TIME_IN_BETWEEN_NOTIFICATIONS )); then
                                printf "$(date): Now trying to notify...\n"
                                curl --form-string "token=${APP_TOKEN}" --form-string "user=${USER_KEY}" \
                                --form-string "message=$message" https://api.pushover.net/1/messages.json
                                date_last_time_called=$(date +%s)
                                printf "\n$(date): Resultcode of curl command was: $?\n"
                        else
                                printf "$(date): Not enough time has passed, will not send out a notification for this file!\n"
                        fi
                fi
        fi
done < <(inotifywait -mr -q -e create --format '%w %f' "${DIR_TO_WATCH}")