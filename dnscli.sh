#!/bin/bash

# Default variable values
connection_name=""
addreses=""

# Function to display script usage
usage() {
    echo "Usage: dnscli [options]"
    echo "Options:"
    echo " -h, --help                   Display this help message"
    echo " -c, --connection=CONNECTION  Specifies the connection to be modified, set CONNECTION to 'auto' to automatically choose the connection"
    echo " -d, --dns='ADDRESSES'        Specifies one to three nameserver addresses. ADDRESSES must be separated by a comma, for example : '8.8.8.8,8.8.4.4.'"
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

# Function to change dns addresses
change_dns() {
    # Replace comma by a space for nmcli                                                       
    local separator=","                                                                              
    local replacement_char=" " 
    local nmcli_arg=$(echo "$2" | sed "s/$separator/$replacement_char/g")
    nmcli connection modify $1 ipv4.dns "$nmcli_arg"
    nmcli con down $1 >& /dev/null && nmcli con up $1 >& /dev/null
}

# Function to test if change_dns worked
check_dns() {
    local separator=" | "
    local replacement_char=","
    local new_dns=$(echo $(nmcli -g IP4.DNS con show $1) | sed "s/$separator/$replacement_char/g")
    if [[ "$new_dns" == $2,* ]]; then
        echo "DNS change completed"
    else
        echo "DNS change failed"
        exit 1
    fi
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
            -d | --dns*)
                if ! handle_argument addresses $@; then
                    echo "Nameserver addresses not specified"
                    usage
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
else
    echo -e "\nNo connection specified\n"
    usage
    exit 1
fi

if [ -n "$addresses" ]; then
    echo "Nameserver addresses to be applied : $addresses"
else
    echo -e "\nError : no nameserver addresses specified\n"
    usage
    exit 1
fi

# Change DNS using nmcli
echo "Previous DNS adresses : $(nmcli -g IP4.DNS con show $connection_name)" 

change_dns $connection_name $addresses
check_dns $connection_name $addresses

echo "New DNS adresses : $(nmcli -g IP4.DNS con show $connection_name)" 
