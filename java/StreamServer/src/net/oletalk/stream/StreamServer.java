/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.SocketAddress;
import org.simpleframework.http.core.ContainerServer;
import org.simpleframework.transport.Server;
import org.simpleframework.transport.connect.Connection;
import org.simpleframework.transport.connect.SocketConnection;

/**
 *
 * @author colin
 */
public class StreamServer {

    private static final int PORT = 7890;
    
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws IOException {
        // TODO code application logic here
        StreamHandler hand = new StreamHandler();
        Server server = new ContainerServer(hand);
        Connection connection = new SocketConnection(server);
        SocketAddress address = new InetSocketAddress(PORT);

        connection.connect(address);
    }
}
