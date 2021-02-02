#!/bin/bash

docker rm -f zoonavigator kafkamanager 
lxc rm -f node1 node2 node3
rm -rvf files/ssl
