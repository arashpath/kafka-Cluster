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
  ```
  nc -vz localhost 9092
  
  ```