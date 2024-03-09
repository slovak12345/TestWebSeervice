
#Create Certificate Authority (CA) Certificate and Key:
openssl genrsa -out ca-key.pem 4096
openssl req -new -x509 -sha256 -key ca-key.pem -out ca-cert.pem -days 365 -subj "/C=US/ST=California/L=Los Angeles/O=Example Company/CN=mydomain.com"

#Create Server Certificate and Key:
openssl genrsa -out server-key.pem 4096
openssl req -new -key server-key.pem -out server.csr -subj "/C=US/ST=California/L=Los Angeles/O=Example Company/CN=mydomain.com"
openssl x509 -req -sha256 -in server.csr -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -days 365

#Create Client Certificate and Key (Optional):
openssl genrsa -out client-key.pem 4096
openssl req -new -key client-key.pem -out client.csr -subj "/C=US/ST=California/L=Los Angeles/O=Example Company/CN=mydomain.com"
openssl x509 -req -sha256 -in client.csr -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out client-cert.pem -days 365
