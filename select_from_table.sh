#!/bin/bash

center_align() {
          local text="$1"
          local width="$2"
          local len=${#text}
          local padding=$(( (width - len) / 2 ))
          #    printf "%${padding}s%s%${padding}s" "" "$text" ""

          printf "%-${width}s" "$(printf "%-${padding}s%s" "" "$text")"
}

echo  -e "${note} ********Database ${dbname} Tables : ************"
         ls  ${path}/${dbname}
echo -e "*******************************************************${NC}"  

      
read -p  "Enter Table Name To Select data : "  tablename
# check table exists
if [ -d $path"/"$dbname"/"$tablename ] ; then

    #load table meta
    # Get column names and datatypes from the table file
    column_names=$(cut -d: -f1 "$path/$dbname/$tablename/${tablename}_meta")
    #column_names=$(sed -n '1p' "$path/$dbname/$tablename")
    column_types=$(cut -d: -f2 "$path/$dbname/$tablename/${tablename}_meta")
    #column_types=$(sed -n '2p' "$path/$dbname/$tablename")
    column_length=$(cut -d: -f3 "$path/$dbname/$tablename/${tablename}_meta")
    echo $column_names
    echo $column_types

    # Prompt the user to enter the data for each column
    data=''
    IFS=$'\n' read -d '' -ra names_array <<< "$column_names"
    IFS=$'\n' read -d '' -ra types_array <<< "$column_types"
    IFS=$'\n' read -d '' -ra length_array <<< "$column_length"

    # check if contains record
    count=`cat $path"/"$dbname"/"$tablename"/"$tablename"_data" | wc -l `

    if [[ $count -gt 0 ]] ; then
    

#      colNames=`cut -d ':' -f 2- $path/$dbname/$tablename`
      echo -e "${invalid} please choose : ${NC}"

      select choice in "Select All Records" "Select Specific Record By Id"     "Select All Values in Specific Column" "Exit"
      do
      case $choice in
      "Select All Records" )

        printf '+';
        for(( i=0; i<${#names_array[@]}; i++ ));do
          printf "-"
          printf "%${length_array[i]}s-+" "$(printf '%*s' "${length_array[i]}" | tr ' ' '-')"
        done
        printf "\n"

        printf '|';
        for(( i=0; i<${#names_array[@]}; i++ ));do
          printf " %s |" "$(center_align ${names_array[$i]} ${length_array[$i]})"
        done

        printf "\n"

        printf "+"
        for(( i=0; i<${#names_array[@]}; i++ ));do
          printf "-"
          printf "%-${length_array[i]}s-+" "$(printf '%*s' "${length_array[i]}" | tr ' ' '-')"

        done
        printf "\n"

        while IFS=: read -r -a fields; do
            printf "|";
            for ((i=0; i<${#names_array[@]}; i++)); do
                printf " %-${length_array[$i]}s |" "${fields[$i]}"
            done
            printf "\n"
        done < "$path/$dbname/$tablename/${tablename}_data"

        printf "+"
        for(( i=0; i<${#names_array[@]}; i++ ));do
          printf "-"
          printf "%-${length_array[i]}s-+" "$(printf '%*s' "${length_array[i]}" | tr ' ' '-')"

        done
        printf "\n"
        ;;


      "Select Specific Record By Id" )
        read -p "Please Enter Record id : " id
        if [[  ! $id =~ ^[1-9][0-9]*$  ]] ; then
            echo -e "${invalid}  Invalid Id  ${NC}"
            source db_menu.sh;

        else
          row=`awk -F":" -v id=$id '{if($1==id) print $0}' $path"/"$dbname"/"$tablename/$tablename"_data"`

          if [[ -z $row ]] ; then
                  echo -e "${invalid} Record Not Found ${NC}"
                  source db_menu.sh;
          else

            printf '+'
            for(( i=0; i<${#names_array[@]}; i++ ));do
              printf "-"
              printf "%-${length_array[i]}s-+" "$(printf '%*s' "${length_array[i]}" | tr ' ' '-')"
            done
              printf "\n"

            printf '|';
            for(( i=0; i<${#names_array[@]}; i++ ));do
              printf " %s |" "$(center_align ${names_array[$i]} ${length_array[$i]})"
            done
            printf "\n"

            printf "+"
            for(( i=0; i<${#names_array[@]}; i++ ));do
              printf "-"
              printf "%-${length_array[i]}s-+" "$(printf '%*s' "${length_array[i]}" | tr ' ' '-')"

            done
            printf "\n"

            printf "|"
            while IFS=: read -r -a fields; do
              for ((i=0; i<${#names_array[@]}; i++)); do
                  printf " %-${length_array[$i]}s |" "${fields[$i]}"
              done
              printf "\n"
            done <<< "$row"

            printf "+"
            for(( i=0; i<${#names_array[@]}; i++ ));do
              printf "-"
              printf "%-${length_array[i]}s-+" "$(printf '%*s' "${length_array[i]}" | tr ' ' '-')"

            done
            printf "\n"
          fi
        fi
        ;;


      "Select All Values in Specific Column")

              echo "Select the column to display all values:"
              select colname in "${names_array[@]}"; do
                  if [[ ! -z $colname ]]; then

                      #TODO: use loop over names_array instead of awk
                      let col_index=$(awk -F":" -v colname="$colname" '{if ($1 == colname) {print NR; exit}}' $path"/"$dbname"/"$tablename"/"$tablename"_meta")
#                      echo "col_index ----> $col_index"
                      col_index=$((col_index-1))

                      printf "+-"
                      printf "%-${length_array[$col_index]}s-+" "$(printf '%*s' "${length_array[$col_index]}" | tr ' ' '-')"
                      printf "\n"

                      printf "| %s |" "$(center_align ${names_array[col_index]} ${length_array[$col_index]})"
                      printf "\n"

                      printf "+-"
                      printf "%-${length_array[$col_index]}s-+" "$(printf '%*s' "${length_array[$col_index]}" | tr ' ' '-')"
                      printf "\n"

                      while IFS=: read -r -a fields; do
                          printf "| %-${length_array[$col_index]}s |" "${fields[$col_index]}"
                          printf "\n"
                      done < "$path/$dbname/$tablename/${tablename}_data"

                      printf "+-"
                      printf "%-${length_array[$col_index]}s-+" "$(printf '%*s' "${length_array[$col_index]}" | tr ' ' '-')"
                      printf "\n"

                  else
                      echo -e "${invalid} Invalid Option ${NC}"
                      source db_menu.sh;
                  fi
                  break
              done
        ;;





      "Exit" ) break ;;
      * ) echo -e "${invalid} Invalid Option ${NC} ";;

      esac
      done


    else
      echo -e "${invalid} Table ${tablename} dose not contain any records ${NC}"
    fi
    source db_menu.sh
else
    echo -e "${invalid} Table  ${tablename} doesnot exist ${NC}"
    source db_menu.sh 
fi
