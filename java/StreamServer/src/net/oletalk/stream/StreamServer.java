/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.SocketAddress;
import java.util.logging.Logger;
import net.oletalk.stream.data.SongList;
import net.oletalk.stream.util.Config;
import net.oletalk.stream.util.LogSetup;
import org.simpleframework.http.core.ContainerServer;
import org.simpleframework.transport.Server;
import org.simpleframework.transport.connect.Connection;
import org.simpleframework.transport.connect.SocketConnection;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

/**
 *
 * @author colin
 */
public class StreamServer {
    
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws IOException {
        // TODO code application logic here
        // Start up
        ApplicationContext applicationContext = new ClassPathXmlApplicationContext("/streamserverContext.xml");
        
        Logger LOG = LogSetup.getlog();

        StreamHandler hand = new StreamHandler();
        Server server = new ContainerServer(hand);
        Connection connection = new SocketConnection(server);
        
        int port = Integer.parseInt(Config.getBean().get("port"));
        SocketAddress address = new InetSocketAddress(port);
        SongList songlist = new SongList();
        songlist.initList(Config.getBean().get("rootdir"));
        hand.setSongList(songlist);
        LOG.info( songlist.toString() );
        
        connection.connect(address);
        System.out.println("Server is now running at port " + port + ", waiting for connections.");
    }
}
