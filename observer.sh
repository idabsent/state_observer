#!/bin/bash

declare -f observer
declare -f date_file_format
declare -f write_logs

function date_file_format()
{
    echo $(date +%+4Y-%m-%d_%H:%M:%S.%N)
}

function write_logs()
{
    declare LOG_DIR=/var/log/observer_logs
    [ -d $LOG_DIR ] || mkdir -p $LOG_DIR

    declare -f write_dmesg_logs
    function write_dmesg_logs()
    {
        declare PATH=$LOG_DIR/dmesg_$(date_file_format).log
        dmesg > $PATH 2>&1 
    }

    write_dmesg_logs 
}

function observer()
{
    declare msg

    declare -i miss_num=0
    declare -i miss_count=10
    declare -i timeout=1

    while [ $miss_num -lt $miss_count ]
    do
        read -t $timeout msg
        if [ -z "$msg" ]; then
            miss_num=$(expr $miss_num + 1)
            echo Missing number $miss_num... >&2
        else 
            miss_num=0
        fi
    done

    if [ $miss_num -eq $miss_count ]; then
        echo All attemptions failed... >&2
        write_logs
    fi
}

observer