#!/bin/bash
# Used to Create CA, SSL Cert & Keystores for kafka and clients
ssl_dir="./files"

echo "Create a CA Authority ..."
openssl req -new \
  -newkey rsa:4096 -days 365 -x509 -subj "/CN=kafka-security-CA" \
  -keyout $ssl_dir/kafka.ca.key -out $ssl_dir/kafka.ca.cert -nodes
keytool -keystore $ssl_dir/kafka.truststore.jks -alias CARoot -import \
  -file $ssl_dir/kafka.ca.cert -storepass kafkats@123 -noprompt
echo "---"

echo "Create keystore for each kafkaSrv and Client ..."
for CN in kafka1 kafka2 kafka3 zookeeper1 zookeeper2 zookeeper3 client
do
  #CN="$i"
  echo "Creating Keystore for $CN ..."
  keytool -genkey -keystore $ssl_dir/$CN.keystore.jks -validity 365 \
    -storepass "$CN"@123 -keypass "$CN"@123 \
    -dname "CN=$CN,OU=IT,O=FSSAI,L=FDA,ST=Delhi,C=IN" \
    -storetype pkcs12 --keyalg RSA -keysize 2048
  #keytool -list -keystore $ssl_dir/$CN.keystore.jks -v -storepass "$CN"@123

  echo "Creating csr for $CN ..."
  # Generate CSR (Certificate Signing Request)
  keytool -keystore $ssl_dir/$CN.keystore.jks -certreq \
    -file $ssl_dir/$CN.csr -storepass "$CN"@123
  echo "Creating cert for $CN  ..."
  # Sign csr with ca
  openssl x509 -req \
    -CA $ssl_dir/kafka.ca.cert -CAkey $ssl_dir/kafka.ca.key \
    -in $ssl_dir/$CN.csr -out $ssl_dir/$CN.cert \
    -days 365 -CAcreateserial
  #keytool -printcert -v -file $ssl_dir/$CN.cert

  echo "Importing Certs to $CN Keystore ..."
  # Import CA.Cert and Cert to keystore
  keytool -keystore $ssl_dir/$CN.keystore.jks -alias CARoot \
    -import -file $ssl_dir/kafka.ca.cert -storepass "$CN"@123 -noprompt
  keytool -keystore $ssl_dir/$CN.keystore.jks \
    -import -file $ssl_dir/$CN.cert -storepass "$CN"@123
  # Removing CSR and CERT files
  #echo "Removing .csr & .cert files for $CN"
  #rm -vf $ssl_dir/$CN.csr $ssl_dir/$CN.cert 
  echo "---"
  
  # 
  if [[ "$CN" == "client" ]]; then 
    echo "Create a zk_client.properties file" 
    echo "# ZooKeeper Client
zookeeper.ssl.client.enable=true
zookeeper.ssl.protocol=TLSv1.2
zookeeper.clientCnxnSocket=org.apache.zookeeper.ClientCnxnSocketNetty
zookeeper.ssl.truststore.location=$ssl_dir/kafka.truststore.jks
zookeeper.ssl.truststore.password=kafkats@123
zookeeper.ssl.keystore.location=$ssl_dir/$CN.keystore.jks
zookeeper.ssl.keystore.password=$CN@123" > $ssl_dir/zk_client.properties
    echo "Create a kafka_client_ssl.properties file" 
    echo "# Kafka Client for SSL
security.protocol=SSL
ssl.protocol=TLSv1.2
#ssl.enabled.protocols=TLSv1.2,TLSv1.1,TLSv1
#ssl.client.auth=required
ssl.truststore.location=$ssl_dir/kafka.truststore.jks
ssl.truststore.password=kafkats@123
ssl.keystore.location=$ssl_dir/$CN.keystore.jks
ssl.keystore.password=$CN@123
ssl.key.password=$CN@123" > $ssl_dir/kafka_client_ssl.properties
    echo "Create a kafka_client_kerberos.properties file"
    echo "# Kafka Client for Kerberos
security.protocol=SASL_SSL
sasl.kerberos.service.name=kafka
ssl.truststore.location=$ssl_dir/kafka.truststore.jks
ssl.truststore.password=kafkats@123" > $ssl_dir/kafka_client_kerberos.properties
  fi
done