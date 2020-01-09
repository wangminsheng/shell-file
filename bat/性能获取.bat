typeperf -f csv -o mycounter.csv counter "\Processor Information(_Total)\%% Processor Time" "\Memory\Available MBytes" "\Network Interface(*)\Bytes Total/sec" "\NVIDIA GPU(*)\%% GPU Usage" -si 2 -sc 100
pause
