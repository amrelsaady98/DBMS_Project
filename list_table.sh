#!/bin/bash

# check if there tables
let count=`ls  $path"/"$dbname | wc -l`
if [[ $count =  1 ]] ; then
echo  -e "${note} ******** You have only one Table *******${NC}"
ls -F $path"/"$dbname 

#<<<<<<< HEAD
elif [[ $count  >   1 ]] ; then
echo  -e "${note} **** You have [${count}] Tables  ****${NC}"
ls -F $path"/"$dbname 
#=======
elif [[ $count  -gt   1 ]] ; then
echo  -e "${note} **** You have [${count}] Tables  ****${NC}"
ls  $path"/"$dbname
#>>>>>>> 3d084c09873a9b393cb4e1202a6e1dc1abebe6df

else
echo -e "${invalid} No Tables Found ${base}"

fi
source db_menu.sh   



