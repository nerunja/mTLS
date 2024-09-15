package org.example;

import javax.net.ssl.*;
import java.io.*;
import java.security.KeyStore;

// to enable logging add jvm arg -Djavax.net.debug=ssl:handshake

public class SimpleServer {

    public static void main(String[] args) throws Exception {

        System.setProperty("javax.net.debug", "ssl,handshake");
        // Load server's key store
        KeyStore keyStore = KeyStore.getInstance("JKS");
        keyStore.load(new FileInputStream("certs/server_keystore.jks"), "serverpass".toCharArray());

        // Set up key manager factory
        KeyManagerFactory keyManagerFactory = KeyManagerFactory.getInstance("SunX509");
        keyManagerFactory.init(keyStore, "serverpass".toCharArray());

        // Load trust store
        KeyStore trustStore = KeyStore.getInstance("JKS");
        trustStore.load(new FileInputStream("certs/server_truststore.jks"), "serverpass".toCharArray());

        // Set up trust manager factory
        TrustManagerFactory trustManagerFactory = TrustManagerFactory.getInstance("SunX509");
        trustManagerFactory.init(trustStore);

        // Set up SSL context
        SSLContext sslContext = SSLContext.getInstance("TLS");
        sslContext.init(keyManagerFactory.getKeyManagers(), trustManagerFactory.getTrustManagers(), null);

        // Create SSL server socket
        SSLServerSocketFactory serverSocketFactory = sslContext.getServerSocketFactory();
        SSLServerSocket serverSocket = (SSLServerSocket) serverSocketFactory.createServerSocket(8443);
        serverSocket.setNeedClientAuth(true);

        System.out.println("Server started...");

        // Accept client connection
        SSLSocket socket = (SSLSocket) serverSocket.accept();
        BufferedReader reader = new BufferedReader(new InputStreamReader(socket.getInputStream()));
        PrintWriter writer = new PrintWriter(socket.getOutputStream(), true);

        // Read and respond to client message
        String message = reader.readLine();
        System.out.println("Received: " + message);
        writer.println("Hello, client!");

        // Close connections
        reader.close();
        writer.close();
        socket.close();
        serverSocket.close();
    }
}
