#!/bin/sh

# This script is intended to be used on SX1302 CoreCell platform, it performs
# the following actions:
#       - export/unpexort GPIO23 and GPIO18 used to reset the SX1302 chip and to enable the LDOs
#
# Usage examples:
#       ./reset_lgw.sh stop
#       ./reset_lgw.sh start

# GPIO mapping has to be adapted with HW
#

SX1302_RESET_PIN=${GW_RESET_GPIO:-17}
SX1302_POWER_EN_PIN=${GW_ENABLE_GPIO:-0}

WAIT_GPIO() {
    sleep 0.1
}

init() {
    
    # setup RESET GPIO
    echo "$SX1302_RESET_PIN" > /sys/class/gpio/export; WAIT_GPIO
    echo "out" > /sys/class/gpio/gpio$SX1302_RESET_PIN/direction; WAIT_GPIO

    # setup ENABLE GPIO
    if [ $SX1302_POWER_EN_PIN -ne 0 ]
    then
        echo "$SX1302_POWER_EN_PIN" > /sys/class/gpio/export; WAIT_GPIO
        echo "out" > /sys/class/gpio/gpio$SX1302_POWER_EN_PIN/direction; WAIT_GPIO
    fi

}

reset() {

    # power concentrator
    if [ $SX1302_POWER_EN_PIN -ne 0 ]
    then
        echo "Concentrator power enable through GPIO$SX1302_POWER_EN_PIN..."
        echo "1" > /sys/class/gpio/gpio$SX1302_POWER_EN_PIN/value; WAIT_GPIO
    fi

    # reset concentrator
    echo "Concentrator reset through GPIO$SX1302_RESET_PIN..."
    echo "1" > /sys/class/gpio/gpio$SX1302_RESET_PIN/value; WAIT_GPIO
    echo "0" > /sys/class/gpio/gpio$SX1302_RESET_PIN/value; WAIT_GPIO

}

term() {

    # cleanup all GPIOs
    if [ -d /sys/class/gpio/gpio$SX1302_RESET_PIN ]
    then
        echo "$SX1302_RESET_PIN" > /sys/class/gpio/unexport; WAIT_GPIO
    fi

    if [ $SX1302_POWER_EN_PIN -ne 0 ]
    then
        if [ -d /sys/class/gpio/gpio$SX1302_POWER_EN_PIN ]
        then
            echo "$SX1302_POWER_EN_PIN" > /sys/class/gpio/unexport; WAIT_GPIO
        fi
    fi

}

case "$1" in
    start)
    term # just in case
    init
    reset
    ;;
    stop)
    reset
    term
    ;;
    *)
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac

exit 0
