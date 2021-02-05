#!/bin/bash

echo "Removing all containers"
docker rm -f zoonavigator kafkamanager
echo "Removing all LxD containers" 
lxc rm -f node1 node2 node3
echo "Removing generated keys"
(cd files/ ; rm -vf *.jks *.cert *.csr *.key *.srl)
echo "Clean Kafka Clients"
rm bin
rm -rf files/kafka_*/
rm client.properties