# REM To generate the keystores and truststores for this mTLS setup, you'll need to use the Java `keytool` utility. Here's a step-by-step guide to create the necessary files:
# REM Totally 24 commands to run

# REM 1. Generate a root CA certificate:
keytool -genkeypair -alias root-ca -keyalg RSA -keysize 2048 -keystore root-ca.jks -validity 3650 -storepass rootpass -keypass rootpass -dname "CN=Root CA,OU=MyOrg,O=MyCompany,L=MyCity,ST=MyState,C=US"
keytool -exportcert -alias root-ca -keystore root-ca.jks -storepass rootpass -file root-ca.cer

# REM 2. Generate an intermediate CA certificate:
keytool -genkeypair -alias intermediate-ca -keyalg RSA -keysize 2048 -keystore intermediate-ca.jks -validity 3650 -storepass intermediatepass -keypass intermediatepass -dname "CN=Intermediate CA,OU=MyOrg,O=MyCompany,L=MyCity,ST=MyState,C=US"

# REM 3. Generate a certificate signing request (CSR) for the intermediate CA:
keytool -certreq -alias intermediate-ca -keystore intermediate-ca.jks -storepass intermediatepass -file intermediate-ca.csr

# REM 4. Sign the intermediate CA certificate with the root CA:
keytool -gencert -alias root-ca -keystore root-ca.jks -storepass rootpass -infile intermediate-ca.csr -outfile intermediate-ca.cer -validity 3650

# REM 5. Import the root CA and intermediate CA certificates into the intermediate CA keystore:
keytool -importcert -alias root-ca -file root-ca.cer -keystore intermediate-ca.jks -storepass intermediatepass -noprompt
keytool -importcert -alias intermediate-ca -file intermediate-ca.cer -keystore intermediate-ca.jks -storepass intermediatepass

# REM 6. Generate server and client keypairs:
keytool -genkeypair -alias server -keyalg RSA -keysize 2048 -keystore server_keystore.jks -validity 365 -storepass serverpass -keypass serverpass -dname "CN=localhost,OU=MyOrg,O=MyCompany,L=MyCity,ST=MyState,C=US"
keytool -genkeypair -alias client -keyalg RSA -keysize 2048 -keystore client_keystore.jks -validity 365 -storepass clientpass -keypass clientpass -dname "CN=client,OU=MyOrg,O=MyCompany,L=MyCity,ST=MyState,C=US"

# REM 7. Generate CSRs for server and client:
keytool -certreq -alias server -keystore server_keystore.jks -storepass serverpass -file server.csr
keytool -certreq -alias client -keystore client_keystore.jks -storepass clientpass -file client.csr

# REM 8. Sign server and client certificates with the intermediate CA:
keytool -gencert -alias intermediate-ca -keystore intermediate-ca.jks -storepass intermediatepass -infile server.csr -outfile server.cer -validity 365
keytool -gencert -alias intermediate-ca -keystore intermediate-ca.jks -storepass intermediatepass -infile client.csr -outfile client.cer -validity 365

# REM 9. Import the certificate chain into server and client keystores:
keytool -importcert -alias root-ca -file root-ca.cer -keystore server_keystore.jks -storepass serverpass -noprompt
keytool -importcert -alias intermediate-ca -file intermediate-ca.cer -keystore server_keystore.jks -storepass serverpass -noprompt
keytool -importcert -alias server -file server.cer -keystore server_keystore.jks -storepass serverpass -noprompt

keytool -importcert -alias root-ca -file root-ca.cer -keystore client_keystore.jks -storepass clientpass -noprompt
keytool -importcert -alias intermediate-ca -file intermediate-ca.cer -keystore client_keystore.jks -storepass clientpass -noprompt
keytool -importcert -alias client -file client.cer -keystore client_keystore.jks -storepass clientpass -noprompt

# REM 10. Create truststores for server and client:
keytool -importcert -alias root-ca -file root-ca.cer -keystore server_truststore.jks -storepass serverpass -noprompt
keytool -importcert -alias intermediate-ca -file intermediate-ca.cer -keystore server_truststore.jks -storepass serverpass -noprompt

keytool -importcert -alias root-ca -file root-ca.cer -keystore client_truststore.jks -storepass clientpass -noprompt
keytool -importcert -alias intermediate-ca -file intermediate-ca.cer -keystore client_truststore.jks -storepass clientpass -noprompt

# REM
# REM After running these commands, you'll have the following files:

# REM - `root-ca.jks`: Root CA keystore
# REM - `intermediate-ca.jks`: Intermediate CA keystore
# REM - `server_keystore.jks`: Server keystore containing its private key and certificate chain
# REM - `client_keystore.jks`: Client keystore containing its private key and certificate chain
# REM - `server_truststore.jks`: Server truststore containing trusted CA certificates
# REM - `client_truststore.jks`: Client truststore containing trusted CA certificates

# REM These files can be used with the Java code provided earlier to set up the mTLS connection between the client and server.

