#!/usr/bin/bash

declare IP_ADDRESS
declare PORT
declare -x EXAMPLE=help

declare OPT_IP_ADDRESS=i
declare OPT_PORT=p

declare -A OPT_DESCRIPTIONS

declare -f usage
declare -f check_args
declare -f fill_descriptions
declare -f main
declare -f lrtrim
declare -f write_logs
declare -f observe
declare -f observer
declare -f date_file_format

function main() {
    local options=":$OPT_IP_ADDRESS:$OPT_PORT:"
    while getopts $options ARG; do
        case $ARG in
        "$OPT_IP_ADDRESS") IP_ADDRESS=$OPTARG;;
        "$OPT_PORT") PORT=$OPTARG;;
        *) usage;;
        esac
    done

    check_args
    observe
}

function observe()
{
    tcpsvd $IP_ADDRESS $PORT ./observer.sh
}

function lrtrim() 
{
    echo $1 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

function check_args()
{
    declare uncorrect=false

    if [ -z "$IP_ADDRESS" ] 
    then echo "Missing option $OPT_IP_ADDRESS..."; uncorrect=true
    fi

    if [ -z "$PORT" ]
    then echo "Missing option $OPT_PORT..."; uncorrect=true
    fi

    [ "$uncorrect" == true ] && usage
}

function usage() 
{
    fill_descriptions

    declare PROGRAM_NAME=observe
    declare DESCRIPTION="
Observe process line througth listen on specific port
    "
    declare DESCRIPTION=$(echo $DESCRIPTION | xargs)
    
    echo -e "$PROGRAM_NAME : $DESCRIPTION"
    echo -e "\t-$OPT_IP_ADDRESS ${OPT_DESCRIPTIONS["$OPT_IP_ADDRESS"]}"
    echo -e "\t-$OPT_PORT ${OPT_DESCRIPTIONS["$OPT_PORT"]}"

    exit 1
}

function fill_descriptions() 
{
    local D_IP_ADDRESS="
IP\tThe listen ip address. Listen to IP:PORT
    "
    local D_PORT="
PORT\tThe listen ip port. Listen to IP:PORT
    "

    OPT_DESCRIPTIONS["$OPT_IP_ADDRESS"]=$(lrtrim "$D_IP_ADDRESS")
    OPT_DESCRIPTIONS["$OPT_PORT"]=$(lrtrim "$D_PORT")
}

if [ "${BASH_SOURCE[0]}" != "$0" ]
then
    echo "not allowed as source file..."
    return
elif [ ! $(id -u) -eq "0" ]
then
    echo script requires root privileges...
    exit 1
else
    main $@
fi