#!/bin/bash

KEY_FILE=.appkey
CFG_FILE=.appcfg


function die(){

echo "$1"
exit $2

}

# encode function
# openssl enc -k secretpassword123 -aes256 -base64 -d -in cipher.txt -out plain_again.txt

function enc(){

	echo "encoder"
}

# decode function

function dec(){
	echo "decoder"

}

# create key function

function set_key(){

local k_val="$1"

if [[ ! -f $KEY_FILE ]];then
	# creating keyfile if not present
	touch $KEY_FILE || die "ERR: Failed to create security key file:[$KEY_FILE]" $?
	# storing provided keyphrase to file
	# if no key provided default will be used
	[[ "$1" != "" ]] && echo "$1" > $KEY_FILE || echo "APP" > $KEY_FILE
else
	# if file is present backup and set the new-one
	mv $KEY_FILE ${KEY_FILE}.$(date +%s) || die "ERR: failed to backup old keyfile:[$KEY_FILE]"
	[[ "$1" != "" ]] && echo "$1" > $KEY_FILE || echo "APP" > $KEY_FILE
fi

# if no issues setting key_present flag
export KEY=1

}

# set-config function

function set_config(){

	# check if we can create configuration file
	[[ ! -f $CFG_FILE ]] && touch $CFG_FILE || die "ERR: Failed to create configuration file: [$CFG_FILE]" $?

	# get param name
	local p_name="$1"
	local p_value="$2"

	# check if parameter is present if not just add new line
	if [[ $(egrep "^${p_name}=.*") -ne 0 ]]; then
		echo "Adding new configuration parameter:[$p_name] to cfg:[$CFG_FILE]"
		echo "${p_name}=${p_value}" >> $CFG_FILE	
	else 
		echo "Updating configuration parameter:[$p_name] in cfg:[$CFG_FILE]"
	fi

	}

function read_config() {
    local ARRAY="$1"
    local KEY VALUE
    local IFS='='
    declare -A "$ARRAY"
    while read; do
        # here assumed that comments may not be indented
        [[ $REPLY == [^#]*[^$IFS]${IFS}[^$IFS]* ]] && {
            read KEY VALUE <<< "$REPLY"
            [[ -n $KEY ]] || continue
            eval "$ARRAY[$KEY]=\"\$VALUE\""
        }
    done
}

function get_config(){

	local p_name="$1"

	# get value for particular param
	[[ ! -f $CFG_FILE ]] && echo "WARN: No configuration file:[$CFG_FILE] present on the system"
	
	# param
	read_config MYCONFIG < "$CFG_FILE"
	echo ${MYCONFIG[${p_name}]}
}

case "$1" in 
	set-key)
	echo "Setting key $2"
	set_key "$2"
	;;
	set-cfg)
	echo "Setting configuration params $2 $3"
	;;
	get-cfg)
	echo "Getting value for parameter $2"
	get_config "$2"
	;;
	*)
	echo -e "Usage:\n $(basename $0) set-key <keyphrase> \n $(basename $0) get-cfg <parameter> \n $(basename $0) set-cfg <parameter> <value>"
	;;
esac


