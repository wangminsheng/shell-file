#!/bin/bash
#ver:0.01 add time 2012/03/29
#for 7641MB InnoLite SATADOM CF card check
#
storage="Patsburg 6-Port SATA AHCI Controller"
CF_CARD="7641MB InnoLite SATADOM"


exp_cf_card(){
  
   rm -rf linkall.cfy
   cp /test/s2r/linkall.cfy .
   exp_cf_card_num=`cat linkall.cfy |grep "FLASH=" |wc -l`
   if [ $exp_cf_card_num -ne 0 ]; then
        print_green "SF Define CF cards number : $exp_cf_card_num"
   else
        print_green "SF not define CF card" |tee -a $Logfile
   fi
}

#7641MB InnoLite SATADOM
get_cf_card(){
   lshw -short >lshw_short.log
   get_cf_card_num=`cat lshw_short.log |grep -A7 "$storage" |grep "$CF_CARD" |wc -l`
}


exp_cf_card
get_cf_card

echo -en "CF card number check " |tee -a $Logfile
if [ $exp_cf_card_num -ne $get_cf_card_num ]; then
  print_red "FAIL [ exp> $exp_cf_card_num get> $get_cf_card_num ]" |tee -a $Logfile
  show_exit
else
  print_green "PASS [ exp > $exp_cf_card_num ]" |tee -a $Logfile
  sleep 1
fi


