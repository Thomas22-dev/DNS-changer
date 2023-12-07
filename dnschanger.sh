#!/bin/bash

# Find the first active connection except loopback
# con_id=$(nmcli -g NAME con show --active | grep -v -x -m 1 "lo")

# read -p "Enter your primary dns adress : " dns_p
# read -p "Enter your secondary dns adress : " dns_s

# echo -e "Configuration to be apply on $con_id :\nPrimary DNS : $dns_p\nSecondary DNS : $dns_s"

# Default variable values
verbose_mode=false
output_file=""

# Function to display script usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo " -h, --help      Display this help message"
    echo " -v, --verbose   Enable verbose mode"
    echo " -f, --file      FILE Specify an output file"
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
            -v | --verbose)
                verbose_mode=true
                ;;
            -f | --file*)
                if ! handle_argument output_file $@; then
                    echo "File not specified." >&2
                    usage
                    exit 1
                fi
                #if ! has_argument $@; then
                #    echo "File not specified." >&2
                #    usage
                #    exit 1
                #fi
                #output_file=$(extract_argument $@)
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
if [ "$verbose_mode" = true ]; then
    echo "Verbose mode enabled."
fi

if [ -n "$output_file" ]; then
    echo "Output file specified: $output_file"
fi
