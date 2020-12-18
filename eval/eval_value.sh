#!/bin/bash
while read NAME VALUE
do
    eval "${NAME}=${VALUE}"
done < name_value.txt
echo "$site $mail $user"
