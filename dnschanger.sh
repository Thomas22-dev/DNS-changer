#!/bin/bash

# Default variable values
connection_name=""

# Function to display script usage
usage() {
    echo "Usage: dnscli {a|c}[h]"
    echo "Options:"
    echo " -h, --help                   Display this help message"
    echo " -c, --connection=CONNECTION  Specifies the connection to be modified, set CONNECTION to 'auto' to automatically choose the connection"
} 

# Function to choose an active connection
auto_detection() {
    local __outputcon=$1
    # Find the first active connection except loopback
    local c=$(nmcli -g NAME con show --active | grep -v -x -m 1 "lo")
    if [ -z "$c" ]; then
        echo "No active connection found." >&2
        return 1
    fi
    eval $__outputcon="'$c'"
}

# Function to check if a connection is active and exists 
is_active() {
    [[ $(nmcli -g NAME con show --active | grep $1) ]];
}

# Functions to handle arguents
has_argument() {
    [[ ("$1" == *=* && -n ${1#*=}) || ( ! -z "$2" && "$2" != -*) ]];
}

extract_argument() {
    if [[ "$1" == *=* ]]; then
        echo ${1#*=}
    else
        echo ${2}
    fi
}

handle_argument() {
    local __outputarg=$1
    shift
    if ! has_argument $@; then
        return 1
    fi
    local arg=$(extract_argument $@)
    eval $__outputarg="'$arg'"
}

shift_argument() {
    [[ ! -z "$2" && "$2" != -* ]]
}

# Function to handle flags
handle_options() {
    while [ $# -gt 0 ]; do
        case $1 in
            -h | --help)
                usage
                exit 0
                ;;
            -a | --auto)
                echo "Not implemented"
                ;;
            -c | --connection*)
                if ! handle_argument connection_name $@; then
                    echo "Connection not specified." >&2
                    usage
                    exit 1
                fi
                if [ "$connection_name" = auto ]; then
                    if ! auto_detection connection_name; then
                        exit 1
                    fi
                fi
                if ! is_active $connection_name; then
                    echo "The specified connection isn't active or doesn't exist"
                    exit 1
                fi
                if shift_argument $@; then
                    shift
                fi
                ;;
            *)
                echo "Invalid option: $1" >&2
                usage
                exit 1
                ;;
        esac
        shift
    done
}

# Main script execution
if [ "$#" = 0 ]; then
    usage
    exit 1
fi
handle_options "$@"

if [ -n "$connection_name" ]; then
    echo "Connection to be modified: $connection_name"
fi
