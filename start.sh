#!/usr/bin/env bash

# Dispatch depending on the concentrator type
if [ -z ${MODEL} ] ;
then
    echo -e "\033[91mWARNING: MODEL variable not set.\n Set the model of the gateway you are using (SX1301, SX1302 or SX1303).\033[0m"
	exit 1
else
    MODEL=${MODEL^^}
    if [ "$MODEL" = "SX1301" ] || [ "$MODEL" = "RAK833" ] || [ "$MODEL" = "RAK2245" ] || [ "$MODEL" = "RAK2247" ] || [ "$MODEL" = "IC880A" ];then
        ./start_sx1301.sh
    fi
    if [ "$MODEL" = "SX1302" ] || [ "$MODEL" = "RAK2287" ];then
        ./start_sx1302.sh
    fi
    if [ "$MODEL" = "SX1303" ] || [ "$MODEL" = "RAK5146" ];then
        ./start_sx1302.sh
    fi
fi
