#!/bin/bash

echo -e "${note} ********Database ${dbname} Tables : ******************"
ls "$path/$dbname"
echo -e "*******************************************************${NC}"

read -p "Please Enter Table Name To Update data: " tablename



# Define the path for the table file
table_file="$path/$dbname/$tablename/${tablename}_data"

if [ -f "$table_file" ]; then
    # Check if the table file contains records (skipping headers or metadata)
    count=$(cat "$table_file" | wc -l)
    if [[ $count -gt 0 ]]; then

        #load table meta
        # Get column names and datatypes from the table file
        column_names=$(cut -d: -f1 "$path/$dbname/$tablename/${tablename}_meta")
        column_types=$(cut -d: -f2 "$path/$dbname/$tablename/${tablename}_meta")
        column_length=$(cut -d: -f3 "$path/$dbname/$tablename/${tablename}_meta")

        IFS=$'\n' read -d '' -ra names_array <<< "$column_names"
        IFS=$'\n' read -d '' -ra types_array <<< "$column_types"
        IFS=$'\n' read -d '' -ra length_array <<< "$column_length"

        read -p "Please Enter Record Id: " id

        if [[ ! $id =~ ^[1-9][0-9]*$ ]]; then
            echo -e "${invalid} Invalid Id ${NC}"
            source db_menu.sh
        else
            # Search for the record with the specified ID and get the current record
            current=$(awk -v id="$id" -F":" '{if ($1==id) print $0}' "$table_file")

            if [[ ! -z $current ]]; then
                record=()
                
                # Loop for fields and data types
                for ((i=1; i<${#names_array[@]}; i++)); do


                    while true ; do

                      echo "Enter New Value Of ${names_array[$i]} [${types_array[$i]}]"
                      read value


                      if [[ ${types_array[$i]} = "VARCHAR" ]]; then
                          if [[ ! $value =~ ^.{1,}$  ]]; then
                              echo -e "${invalid} ${names_array[$i]} must be a string ${NC}"
                          else
  #                            value=$(echo "$value" | tr ' ' '_')
                              record[$i]=$value
                              break;
                          fi

                      elif [[ ${types_array[$i]} = "INTEGER" ]]; then


                          if [[ ! $value =~ ^[0-9]*$ ]]; then
                              echo -e "${invalid} ${names_array[$i]} must be an integer ${NC}"
                          else
                              record[$i]=$value
                              break;
                          fi

                      elif [[ ${types_array[$i]} = "DATE" ]]; then
                          if [[ ! $value =~ ^(0[1-9]|[12][0-9]|3[01])-(0[1-9]|1[0-2])-([0-9]{4})$ ]]; then
                              echo -e "${invalid} ${names_array[$i]} must be a DATE ${NC}"
                          else
                              record[$i]=$value
                              break;
                          fi
                      fi

                    done

                    if [ ${length_array[$i]} -lt $(echo  $value | wc -c) ]; then
                      awk -v line_num=$(($i+1)) -v new_length=$(echo  $value | wc -c) -F: '
                      {
                      if (NR == line_num) {
                      $3 = new_length;
                      }
                      print $0;
                      }' OFS=: "$path/$dbname/$tablename/${tablename}_meta" > "$path/$dbname/$tablename/${tablename}_meta.tmp"

                      # Move the temporary file to replace the original file
                      mv "$path/$dbname/$tablename/${tablename}_meta.tmp"  "$path/$dbname/$tablename/${tablename}_meta"
                    fi
                done

                # Combine the updated record
                data=""
                for item in "${record[@]}"; do

                    data+="$item:"
                done
                data="$id:${data%":"}"  # Remove the trailing " | "

                updateRecord="${data}"
                sed -i "/^$id/s/$current/$updateRecord/" "$table_file"

            else
                echo -e "${invalid} Record Not Found ${NC}"
                source db_menu.sh
            fi
        fi

        echo -e "${note} Record Updated Successfully. ${NC}"
        source db_menu.sh

    else
        echo -e "${invalid} Table ${tablename} does not contain any records ${NC}"
        source db_menu.sh
    fi

else
    echo -e "${invalid} Table ${tablename} does not exist ${NC}"
    source db_menu.sh
fi