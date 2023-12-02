#!/bin/bash

set +x

echo N > /sys/module/dmatest/parameters/polled
DSA_CONFIG_PATH=/sys/bus/dsa/devices
DSA_BIND_PATH=/sys/bus/dsa/drivers/dsa/bind
DSA_UNBIND_PATH=/sys/bus/dsa/drivers/dsa/unbind
DSA_PCI_DEVICE="0000:00:03.0"
DSA_TEST_ITERATIONS=5

# DSA0 config

# set engine 0 to group 0
echo 0 > $DSA_CONFIG_PATH/dsa0/engine0.0/group_id

# setup group 0
echo 0 > $DSA_CONFIG_PATH/dsa0/wq0.0/group_id
echo dedicated > $DSA_CONFIG_PATH/dsa0/wq0.0/mode
echo 10 > $DSA_CONFIG_PATH/dsa0/wq0.0/priority
echo 16 > $DSA_CONFIG_PATH/dsa0/wq0.0/size
echo 0 > $DSA_CONFIG_PATH/dsa0/engine0.0/group_id
echo 0 > $DSA_CONFIG_PATH/dsa0/engine0.1/group_id
echo 1 > $DSA_CONFIG_PATH/dsa0/wq0.0/block_on_fault

echo "kernel" > $DSA_CONFIG_PATH/dsa0/wq0.0/type
echo "dmaengine" > $DSA_CONFIG_PATH/dsa0/wq0.0/name
echo "dmaengine" > $DSA_CONFIG_PATH/dsa0/wq0.0/driver_name
echo "Engines for group 0"
cat $DSA_CONFIG_PATH/dsa0/group0.0/engines
echo "Work queues for group 0"
cat $DSA_CONFIG_PATH/dsa0/group0.0/work_queues

echo "enable dsa0"
echo dsa0 > $DSA_BIND_PATH
echo "enable wq0.0"
echo wq0.0 > $DSA_BIND_PATH


#modprobe dmatest
echo "Run DMA test"
echo $DSA_TEST_ITERATIONS > /sys/module/dmatest/parameters/iterations
echo 1 > /sys/module/dmatest/parameters/verbose
echo 1 > /sys/module/dmatest/parameters/norandom
echo 4096 > /sys/module/dmatest/parameters/test_buf_size
echo 0 > /sys/module/dmatest/parameters/noverify
echo 12 > /sys/module/dmatest/parameters/alignment
echo $DSA_PCI_DEVICE > /sys/module/dmatest/parameters/device
echo "" > /sys/module/dmatest/parameters/channel

echo 1 > /sys/module/dmatest/parameters/run
sleep 2
echo 0 > /sys/module/dmatest/parameters/run
dmesg | grep dmatest

echo "disable wq0.0"
echo wq0.0 > $DSA_UNBIND_PATH
echo "disable dsa0"
echo dsa0 > $DSA_UNBIND_PATH
