# Apace Kafka

## Zookeeper
- Disable swap
- Ports: 2181,2888,3888
- Access
  ```bash
  # Shell Access
  bin/zookeeper-shell.sh localhost:2181
  # Web UI
  # https://github.com/elkozmon/zoonavigator
  docker run \
    -d --network host \
    -e HTTP_PORT=9001 \
    --name zoonavigator \
    --restart unless-stopped \
    elkozmon/zoonavigator:latest
  ```
- 4letter words
  ```bash
  nc -vz localhost 2181
  echo "srvr" |  nc localhost 2181 ; echo
  echo "ruok" |  nc localhost 2181 ; echo
  echo "stat" |  nc localhost 2181 ; echo
  ```

## Kafka
- Set file limit
  ```bash
  echo "* hard nofile 100000
  * soft nofile 100000" | sudo tee --append /etc/security/limits.conf
  ```
- Port: 9092
- test
  ```bash
  nc -vz localhost 9092
  # not required as auto.create.topics.enable=true
  # ./bin/kafka-topics.sh --zookeeper zookeeper1:2181/kafka --create --topic first_topic   --replication-factor 1 --partitions 3
  ./bin/kafka-console-producer.sh --broker-list kafka1:9092 --topic first_topic
  ./bin/kafka-console-consumer.sh --bootstrap-server kafka1:9092 --topic first_topic --from-beginning
  ./bin/kafka-topics.sh --zookeeper zookeeper1:2181/kafka --list
  ```
- Fix
  ```bash
  # in case not working after adding to cluster
  ./bin/kafka-topics.sh --zookeeper zookeeper1:2181/kafka --config min.insync.replicas=1 --topic __consumer_offsets --alter
  ```
- Kafka Manager 
  ```bash
  # https://github.com/qnib/plain-kafka-manager
  # https://github.com/yahoo/CMAK
  docker run \
    -d --network host \
    -e  ZOOKEEPER_HOSTS="zookeeper1:2181,zookeeper2:2181,zookeeper3:2181" \
    --name kafkamanager \
    --restart unless-stopped \
    qnib/plain-kafka-manager:latest
  ```
- Kafka Load
  ```bash
  # Create a topic
  ./bin/kafka-topics.sh --zookeeper zookeeper1:2181,zookeeper2:2181,zookeeper3:2181/kafka --create --topic fourth_topic   --replication-factor 3 --partitions 3
  # Generate a 10KB file
  base64 /dev/urandom | head -c 10000 | egrep -ao "\w" | tr -d "\n" > file10KB.txt
  # Start a Continious producer
  bin/kafka-producer-perf-test.sh --topic fourth_topic \
    --num-records 10000 --throughput 10 \
    --payload-file file10KB.txt --payload-delimiter A \
    --producer-props acks=1 bootstrap.servers=kafka1:9092,kafka2:9092,kafka3:9092
  # Start a Consumer
  bin/kafka-console-consumer.sh --bootstrap-server kafka1:9092,kafka2:9092,kafka3:9092 --topic fourth_topic
  ```