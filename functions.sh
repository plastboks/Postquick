#!/bin/bash
#
# Some functions for Postquick
#


# Random string generation.
# Function found @ the interwebs
# http://utdream.org/post.cfm/bash-generate-a-random-string
function randomstring {
    # if a param was passed, it's the length of the string we want
    # otherwise set to default
    if [[ -n $1 ]] && [[ "$1" -lt 20 ]]; then
        local myStrLength=$1;
    else
        local myStrLength=8;
    fi

    local mySeedNumber=$$`date +%N`; # seed will be the pid + nanoseconds
    local myRandomString=$( echo $mySeedNumber | md5sum | md5sum );
    # create our actual random string
    myRandomResult="${myRandomString:2:myStrLength}"
}
