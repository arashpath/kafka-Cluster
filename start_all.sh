#!/bin/bash

# Generate SSL Certs 
./gen_ssl.sh
# Set Up Kubernets Cluster
./playbook.yml

# Check ZooKeeper
for i in 1 2 3; do nc -vz kafka$i 2181; done
# Start ZooNavigator 
docker run \
  -d --network host \
  -e HTTP_PORT=9001 \
  --name zoonavigator \
  --restart unless-stopped \
  elkozmon/zoonavigator:latest

# Check Kafka
for i in 1 2 3; do nc -vz kafka$i 9092; done
# Start KafkaManager
docker run \
  -d --network host \
  -e  ZOOKEEPER_HOSTS="zookeeper1:2181,zookeeper2:2181,zookeeper3:2181" \
  --name kafkamanager \
  --restart unless-stopped \
  qnib/plain-kafka-manager:latest

# Unzip kafka for Client
file=$(ls files/kafka_*.tgz)
tar -xzf $file -C files/
ln -s ${file%.*}/bin bin