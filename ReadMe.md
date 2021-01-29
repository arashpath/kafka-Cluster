# Apace Kafka

## Zookeeper
- Disable swap
- Ports: 2181,2888,3888
- Access
  ```bash
  # Shell Access
  bin/zookeeper-shell.sh localhost:2181
  # Web UI
  docker run \
    -d --network host \
    -e HTTP_PORT=9000 \
    --name zoonavigator \
    --restart unless-stopped \
    elkozmon/zoonavigator:latest
  ```
- 4letter words
  ```bash
  echo "ruok" |  nc localhost 2181 ; echo
  echo "stat" |  nc localhost 2181 ; echo
  nc -vz localhost 2181
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
  # ./bin/kafka-topics.sh --zookeeper zookeeper1:2181/kafka --create --topic first_topic --replication-factor 1 --partitions 3
  ./bin/kafka-console-producer.sh --broker-list kafka1:9092 --topic first_topic
  ./bin/kafka-console-consumer.sh --bootstrap-server kafka1:9092 --topic first_topic --from-beginning
  ./bin/kafka-topics.sh --zookeeper zookeeper1:2181/kafka --list
  ```