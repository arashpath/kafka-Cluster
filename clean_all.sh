#!/bin/bash

docker rm -f zoonavigator kafkamanager 
lxc rm -f node1 node2 node3
(cd files/ ; rm -vf *.jks *.cert *.csr *.key *.srl)