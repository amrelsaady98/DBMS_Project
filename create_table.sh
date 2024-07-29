#!/bin/bash

# get table name and make some validations

read -p "pls Enter table name : " tablename
while [[ -z $tablename || $tablename =~ ^[0-9] || $tablename == *['~`!@#$%^&*-+=/|\:.,;''"?><}{)(][']* ]]
do
  echo -e "$invalid Invalid table name $NC"
  read -p "pls Enter table name : " tablename
done

#convert spaces to underscore (_)
tablename=$(echo "$tablename" | tr ' ' '_')

if [ -d $path/$dbname/$tablename ]; then
  #table exist return to menu
  echo -e "${invalid} Table ${tablename} already exists ${NC}"
else

    #create data storage file
  mkdir $path/$dbname/$tablename
  touch $path/$dbname/$tablename/"${tablename}_data"
  touch $path/$dbname/$tablename/"${tablename}_meta"
#  touch $path/$dbname/"${tablename}_meta"

  echo -e "${note} Table ${tablename} created succssfull! ${NC}"

  # create metadata of table
  read -p "Enter number of columns for table ${tablename} : " numcolumns
  # validations on column number and convert it to integer
  while ! [[ $numcolumns =~ ^[1-9][0-9]*$ ]]
  do
  echo -e "$invalid Invaild number $NC"
  read -p "Enter number of columns for table ${tablename} : " numcolumns
  done

  # convert tablename to integer  to operate
   let numcolumns=$numcolumns

  # DB engine does not accept less than two columns
  # the table can not be empty

  while [[ $numcolumns -lt 2 ]]
  do
  echo -e "$invalid Minimum Number Of Columns is 2 $NC"
  read -p "Enter number of columns for table ${tablename} : " numcolumns
  done



  # by default first column is id and the constraint on it is PK
  echo -e "${note} Note the first column name is id and it is PK ${NC}"
  #loop on number of columns (numcolumns) to get the name&type of each column (string || int || )
  column_name=('id')
  column_type=('integer')
  temp_col_name=''
  temp_col_type=''
  columns_list=('id:INTEGER:8')
  for ((i=2;i<=$numcolumns;i++))
  do
  read -p "Enter column ${i} Name : " colName

  # make validations on column name

  while [[ -z $colName || $colName =~ ^[0-9] || $colName == *['~`!@#$%^&*-+=/|\:.,;''"?><}{)(][']* ]]
  do
  echo -e "$invalid Invalid Column Name $NC"
  read -p "pls Enter Column ${i} Name : " colName
  done

  #convert spaces to underscore in column name
  colName=$(echo "$colName" | tr ' ' '_')

  # check if the column exist or not
  while [[ "${column_name[@]}" =~ "$colName" ]] ;
  do
  echo -e "${invalid} column ${colName} exist ${NC}"
  read -p "pls Enter Column $i Name : " colName
  done

  # Append column name to the existing names
  column_name+="|$colName"


   # Get data type for the column
   echo -e "${note} Enter Data Types [VARCHAR|INTEGER|DATE] for column $colName ${NC}"
  select choice in "VARCHAR" "INTEGER" "DATE" ;
  do
  case $choice in
  "VARCHAR" )
  column_type+="|VARCHAR";
  columns_list+=("${colName}:VARCHAR:$(echo -n $colName | wc -c)")
  break;;
  "INTEGER" )
  column_type+="|INTEGER";
  columns_list+=("${colName}:INTEGER:$(echo -n $colName | wc -c)")
  break;;
  "DATE" ) column_type+="|DATE";
  columns_list+=("${colName}:DATE:$(echo -n $colName | wc -c)")
  break;;
  * ) echo -e "${invalid}Invalid data type${NC}";
  continue;;
  esac
  done

  done

  # write column name and thier datatype in the table file
  echo $column_name >> $path/$dbname/$tablename
  echo $column_type >> $path/$dbname/$tablename
  echo -e "${note} your table [$tablename] metadata is : \n $column_name \n -----------------------------------------------------------------------------------------------------------------\n$column_type ${NC}"
  echo ${columns_list}
  for i in "${!columns_list[@]}"; do
    echo "Item $i: ${columns_list[$i]}"
    echo ${columns_list[$i]} >> $path/$dbname/$tablename/"${tablename}_meta"
done
fi
source db_menu.sh
