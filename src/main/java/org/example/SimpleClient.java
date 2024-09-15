package org.example;

import javax.net.ssl.*;
import java.io.*;
import java.security.KeyStore;

// to enable logging add jvm arg -Djavax.net.debug=ssl:handshake

public class SimpleClient {
    public static void main(String[] args) throws Exception {

        System.setProperty("javax.net.debug", "ssl,handshake");
        // Load client's key store
        KeyStore keyStore = KeyStore.getInstance("JKS");
        keyStore.load(new FileInputStream("certs/client_keystore.jks"), "clientpass".toCharArray());

        // Set up key manager factory
        KeyManagerFactory keyManagerFactory = KeyManagerFactory.getInstance("SunX509");
        keyManagerFactory.init(keyStore, "clientpass".toCharArray());

        // Load trust store
        KeyStore trustStore = KeyStore.getInstance("JKS");
        trustStore.load(new FileInputStream("certs/client_truststore.jks"), "clientpass".toCharArray());

        // Set up trust manager factory
        TrustManagerFactory trustManagerFactory = TrustManagerFactory.getInstance("SunX509");
        trustManagerFactory.init(trustStore);

        // Set up SSL context
        SSLContext sslContext = SSLContext.getInstance("TLS");
        sslContext.init(keyManagerFactory.getKeyManagers(), trustManagerFactory.getTrustManagers(), null);

        // Create SSL socket
        SSLSocketFactory socketFactory = sslContext.getSocketFactory();
        SSLSocket socket = (SSLSocket) socketFactory.createSocket("localhost", 8443);

        // Send message to server
        PrintWriter writer = new PrintWriter(socket.getOutputStream(), true);
        BufferedReader reader = new BufferedReader(new InputStreamReader(socket.getInputStream()));

        writer.println("Hello, server!");
        String response = reader.readLine();
        System.out.println("Received from server: " + response);

        // Close connections
        reader.close();
        writer.close();
        socket.close();
    }
}
