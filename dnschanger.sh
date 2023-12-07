#!/bin/bash

# Find the first active connection except loopback
# con_id=$(nmcli -g NAME con show --active | grep -v -x -m 1 "lo")

# read -p "Enter your primary dns adress : " dns_p
# read -p "Enter your secondary dns adress : " dns_s

# echo -e "Configuration to be apply on $con_id :\nPrimary DNS : $dns_p\nSecondary DNS : $dns_s"

# Default variable values
auto_detect=false
i_mode=false
interface=""

# Function to display script usage
usage() {
    echo "Usage: dnscli {a|i}[h]"
    echo "Options:"
    echo " -h, --help                   Display this help message"
    echo " -a, --auto                   Automatically selects the network interface to be modified"
    echo " -i, --interface=INTERFACE    Specifies the network interface to be modified"
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
                if [ "$i_mode" = true ]; then
                    echo "Cannot use interface and automatic mode at the same time."
                    usage
                    exit 1
                fi
                auto_detect=true
                interface=$(nmcli -g NAME con show --active | grep -v -x -m 1 "lo")
                ;;
            -i | --interface*)
                if [ "$auto_detect" = true ]; then
                    echo "Cannot use interface and automatic mode at the same time."
                    usage
                    exit 1
                fi
                if ! handle_argument interface $@; then
                    echo "Interface not specified." >&2
                    usage
                    exit 1
                fi
                i_mode=true
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
handle_options "$@"

# Perform the desired actions based on the provided flags and arguments
if [ "$auto_detect" = true ]; then
    echo "Automatic detection enabled."
fi

if [ -n "$interface" ]; then
    echo "Interface to be modified: $interface"
fi
