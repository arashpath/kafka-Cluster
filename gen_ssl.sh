#!/bin/bash
# Used to Create CA, SSL Cert & Keystores for kafka and clients
cert_folder="./files/ssl"
mkdir $cert_folder

echo "Create a CA Authority ..."
openssl req -new \
  -newkey rsa:4096 -days 365 -x509 -subj "/CN=kafka-security-CA" \
  -keyout $cert_folder/kafka.ca.key -out $cert_folder/kafka.ca.cert -nodes
keytool -keystore $cert_folder/kafka.ts.jks -alias CARoot -import \
  -file $cert_folder/kafka.ca.cert -storepass kafkats@123 -noprompt
echo "---"

echo "Create keystore for each kafkaSrv and Client ..."
for i in 1 2 3 _client
do
  node="kafka$i"
  echo "Creating Keystore for $node ..."

  keytool -genkey -keystore $cert_folder/$node.ks.jks -validity 365 \
    -storepass "$node"@123 -keypass "$node"@123 \
    -dname "CN=$node,OU=IT,O=FSSAI,L=FDA,ST=Delhi,C=IN" \
    -storetype pkcs12 --keyalg RSA -keysize 2048
  #keytool -list -keystore $cert_folder/$node.ks.jks -v -storepass "$node"@123

  echo "Creating Signed Cert for $node ..."
  # Generate CSR (Certificate Signing Request)
  keytool -keystore $cert_folder/$node.ks.jks -certreq \
    -file $cert_folder/$node.ks.csr -storepass "$node"@123
  # Sign csr with ca
  openssl x509 -req \
    -CA $cert_folder/kafka.ca.cert -CAkey $cert_folder/kafka.ca.key \
    -in $cert_folder/$node.ks.csr -out $cert_folder/$node.ks.cert \
    -days 365 -CAcreateserial
  #keytool -printcert -v -file $cert_folder/$node.ks.cert
  # Import CA.Cert and Cert to keystore
  keytool -keystore $cert_folder/$node.ks.jks -alias CARoot \
    -import -file $cert_folder/kafka.ca.cert -storepass "$node"@123 -noprompt
  keytool -keystore $cert_folder/$node.ks.jks \
    -import -file $cert_folder/$node.ks.cert -storepass "$node"@123
  echo "---"
  echo "Create a client.properties file"
  [ $i == _client ]; echo "
security.protocol=SSL
ssl.truststore.location=$cert_folder/kafka.ts.jks
ssl.truststore.password=kafkats@123
ssl.keystore.location=$cert_folder/$node.ks.jks
ssl.keystore.password="$node"@123
ssl.key.password="$node"@123
ssl.enabled.protocols=TLSv1.2,TLSv1.1,TLSv1
ssl.client.auth=required
  " > client.properties
done

