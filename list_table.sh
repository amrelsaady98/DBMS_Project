#!/bin/bash

# check if there tables
let count=`ls  $path"/"$dbname | wc -l`
if [[ $count =  1 ]] ; then
echo  -e "${note} ******** You have only one Table *******${NC}"
ls -F $path"/"$dbname 

#<<<<<<< HEAD
elif [[ $count  >   1 ]] ; then
echo  -e "${note} **** You have [${count}] Tables  ****${NC}"
printf "+-%-20s-+\n" "$(printf '%*s' "20" | tr ' ' '-')"
for entry in $path"/"$dbname/*; do
    if [ -d "$entry" ]; then
        mod_date=$(stat -c "%y" "$entry" | cut -d'.' -f1)
        name=$(basename "$entry")

        # Print each directory in a formatted way
        printf "| %-20s |\n" "$name"
        printf "+-%-20s-+\n" "$(printf '%*s' "20" | tr ' ' '-')"
    fi
done
##=======
#elif [[ $count  -gt   1 ]] ; then
#echo  -e "${note} **** You have [${count}] Tables  ****${NC}"
##ls  $path"/"$dbname
#
#printf "+-%-20s-+\n" "$(printf '%*s' "20" | tr ' ' '-')"
#for entry in $path"/"$dbname/*; do
#    if [ -d "$entry" ]; then
#        mod_date=$(stat -c "%y" "$entry" | cut -d'.' -f1)
#        name=$(basename "$entry")
#
#        # Print each directory in a formatted way
#        printf "| %-20s |\n" "$name"
#        printf "+-%-20s-+\n" "$(printf '%*s' "20" | tr ' ' '-')"
#    fi
#done

else
echo -e "${invalid} No Tables Found ${base}"

fi
source db_menu.sh   



