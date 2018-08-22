#!/bin/bash

while [ 1 ]
 do
   clear

   OK=1
   while [ $OK -ne 0 ]
   do
     read -p "Please input the number of loop for test (digit of [0-9])----->" Loop
     echo "$Loop"| grep '^[0-9]*$' > /dev/null
     OK=$?
   done
   echo "Total loops for UUT:$Loop" > titleloop
   echo "$Loop" > userloop

 

done
cat titleloop titleprojectname configno hardwarerev psurev comment > title
cat title > "$LogFileName"
