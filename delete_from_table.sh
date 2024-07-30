
echo -e "${note} ********Database ${dbname} Tables : ************"
ls "$path/$dbname"
echo -e "*******************************************************${NC}"

read -p "Enter Table Name To Delete data: " tablename

table_file="$path/$dbname/$tablename/${tablename}_data"

# Check if the table file exists
if [ -f "$table_file" ]; then
    # Check if the data file contains records
    count=$(cat "$table_file" | wc -l)

    
    if [ "$count" -gt 0 ]; then
        echo -e "${invalid} Please choose: ${NC}"
        select choice in "Delete All Records" "Delete Specific Record By Id" "Exit"
        do
            case $choice in
                "Delete All Records")
                    echo -e "${invalid} Are you sure to delete all records from ${tablename}? [y/n]: ${NC}"
                    read ans
                    if [[ $ans == "y" || $ans == "Y" ]]; then
                        # Delete all records except headers or metadata
                        sed -i '1,$d' "$table_file"
                        echo -e "${note} ${tablename} Records deleted successfully. ${NC}"
                        source db_menu.sh
                    fi
                    ;;

                "Delete Specific Record By Id")
                    read -p "Please Enter Record id: " id
                    if [[ ! $id =~ ^[1-9][0-9]*$ ]]; then
                        echo -e "${invalid} Invalid Id ${NC}"
                        source db_menu.sh
                    else
                        row=$(awk -F ":" -v id="$id" '$1==id {print $0}' "$table_file")
                        if [[ -z $row ]]; then
                            echo -e "${invalid} Record Not Found ${NC}"
                            source db_menu.sh
                        else
                            echo -e "${invalid} Are you sure to delete Record ${row}? [y/n]: ${NC}"
                            read ans
                            if [[ $ans == "y" || $ans == "Y" ]]; then
                                # Delete the specific record
                                sed -i "/^$id:/d" "$table_file"
                                echo -e "${note} Record deleted from ${tablename} successfully ${NC}"
                            fi
                            source db_menu.sh
                        fi
                    fi
                    ;;

                "Exit")
                    break
                    source db_menu.sh
                    ;;

                *)
                    echo -e "${invalid} Invalid choice ${NC}"
                    source db_menu.sh
                    ;;
            esac
        done
    else
        echo -e "${invalid} Table ${tablename} does not contain any records ${NC}"
        source db_menu.sh
    fi
else
    echo -e "${invalid} Table ${tablename} does not exist ${NC}"
    source db_menu.sh
fi