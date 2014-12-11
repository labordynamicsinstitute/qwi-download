#!/bin/bash
for arg in \
 $(grep "End of Column names" csv_description.txt | awk ' { print $10 } ')
do 
  if [[ -f $arg || -f ${arg}.gz ]] 
  then
	echo "Found $arg " 
  else
        echo "Missing $arg"
  fi
done
