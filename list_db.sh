#!/bin/bash

# check if there databases
count=$(ls ${path} | wc -l)

if [[ $count =  1 ]] ; then
echo  -e "${note} ******** You have only one Database *******${NC}"
ls -F ${path} | tr '/' ' '
elif [[ $count -gt  1 ]] ; then
echo  -e "${note} **** You have [${count}] Databases  ****${NC}"

printf "+-%-20s-+\n" "$(printf '%*s' "20" | tr ' ' '-')"
for entry in "$path"/*; do
    if [ -d "$entry" ]; then
        mod_date=$(stat -c "%y" "$entry" | cut -d'.' -f1)
        name=$(basename "$entry")

        # Print each directory in a formatted way
        printf "| %-20s |\n" "$name"
        printf "+-%-20s-+\n" "$(printf '%*s' "20" | tr ' ' '-')"
    fi
done


else
echo -e "${invalid} No Databases Found ${NC}"
fi

source main.bash
