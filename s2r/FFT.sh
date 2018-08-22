#!/bin/bash

ipmitool sel clear #2012/02/03
sleep 1
# [ 1 ]==============      FRU write/read check      ===========================
cd /test/s2r/fru
if ! source ./fft_fru.sh ; then
 itemfail "Load fru.sh FAIL !!!"
 show_exit
fi
# [ 2 ]====================    front board Part number check    ================
if ! source ./fp_fru_chk.sh ; then
  itemfail "Load fp_fru_chk.sh FAIL !!!"
  show_exit
fi

# [ 3 ]====================    front board identify check   ====================
cd /test/s2r/bmc
if ! source ./fft_identify_chk.sh ; then
  itemfail "Load identify_chk.sh FAIL !!!"
  show_exit
fi

# [ 4 ]=============================== USB Check ===============================
#cd /test/s2r/config
#if ! source ./usb_chk.sh ; then
#  itemfail "Load usb_chk.sh FAIL !!!"
#  show_exit
#fi

# [ 5 ]=====================    BIOS Version check      ========================
cd /test/s2r/bios
if ! source ./bios_ver_chk.sh ; then
 itemfail "BIOS Version Check FAIL !!!"
 show_exit
fi

# [ 6 ]====================    BMC Version check       =========================
cd /test/s2r/bmc
if ! source ./bmc_ver_chk.sh ; then 
 itemfail "Load bmc_ver_chk.sh FAIL !!!"
 show_exit
fi

# [ 7 ]=====================   UUID and BMC Mac check    =======================
cd /test/s2r/config
if ! source ./uuid_chk.sh ; then
  itemfail "Load uuid_chk.sh FAIL !!!"
  show_exit
fi

# [ 8 ]============================= LAN MAC Check   ===========================
if ! source ./lanmac_chk.sh ; then
  itemfail "Load lanmac_chk.sh FAIL !!!"
  show_exit
fi

# [ 9 ]============================= LOM Firmware Check ========================
if ! source ./lom_fw_chk.sh ; then
  itemfail "Load lom_fw_chk.sh FAIL !!!"
  show_exit
fi

# [ 10 ]============================ FAN test check ============================
cd /test/s2r/bmc
if ! source ./fan_test.sh; then
  itemfail "Load fan_test.sh FAIL !!!"
  show_exit
fi

# [ 11 ]===========================P3V bat voltage test ========================
if ! source ./voltage.sh; then
  itemfail "Loade voltage.sh FAIL !!!"
  show_exit
fi

# [ 12 ]==========================QCIxDiag test ================================
cd /test/s2r/QCILxDiag_V10
rm -f Output.log
if ! source diag6.sh  ; then
  itemfail "load diag6.sh fail !!!"
  show_exit
fi
retstr=`egrep -i 'FAIL' Output.log`
  if [ ! -z "$retstr" ]; then
    print_red "qcixdiag test fail" |tee -a $Logfile    
    export linuxdiag=FAIL
		itemfail "$retstr !!!" |tee -a $Logfile
    show_exit
  else
    print_green "qcixdiag test pass" |tee -a $Logfile     
    export linuxdiag=PASS
    itempass "qcixdiag test pass !!!" |tee -a $Logfile
  fi
  
# [ 13 ]=========================== write cmos check ===========================
#cd /test/s2r/cmos
#if ! source ./wrcmos.sh ; then
# itemfail "No wrcmos.sh to write bios setting !!!"
# show_exit
#fi

#[ 14 ]============================ PING BMC port test==========================
cd /test/s2r/bmc
if ! source ./ping_test.sh ; then
  itemfail "ping test FAIL"
  show_exit
fi

# [ 15 ]============================ record SEL log =============================
echo "----record sel log to test log-----" >>$Logfile
ipmitool sel elist -v >>$Logfile
echo "-----------------------------------" >>$Logfile
echo "" >>$Logfile
echo "---record sdr to test_log----------" >>$Logfile
ipmitool sdr list >>$Logfile
echo "-----------------------------------" >>$Logfile

sleep 2
# [ 16 ]=============================sel check =================================
if ! source ./sel_chk.sh ;then
  itemfail "Sel check FAIL"
  show_exit
fi

# [ 17 ]=======set chassis policy always-off====================================
if ! source ./chassis_status_set.sh ;then
  itemfail "set chssis status alwayoff fail"
  show_exit
fi

ipmitool sel clear
sleep 2
print_green "Clear BMC Event Log OK" |tee -a $Logfile