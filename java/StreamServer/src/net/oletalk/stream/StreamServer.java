/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream;

import java.io.IOException;
import java.net.SocketAddress;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.annotation.PostConstruct;
import net.oletalk.stream.util.LogSetup;
import org.simpleframework.transport.connect.Connection;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;

/**
 *
 * @author colin
 */
public class StreamServer {
    
    
    private @Value("${port}") String port;

    private static final Logger LOG = LogSetup.getlog();
    
    @Autowired
    Connection connection;
    
    @Autowired
    SocketAddress address;
    
    public void startup() throws IOException
    {
        connection.connect(address);
        LOG.log(Level.INFO, "Server is now running at port {0}, waiting for connections.", port);
    }
    /**
     * @param args the command line arguments
     */
    /*
     *     public static void main(String[] args) throws IOException {
        // TODO code application logic here
        // Start up
        ApplicationContext applicationContext = new ClassPathXmlApplicationContext("/streamserverContext.xml");
        
        Logger LOG = LogSetup.getlog();

        Connection connection = applicationContext.getBean("connxion", Connection.class);
        
        int port = Integer.parseInt(Config.getBean().get("port"));
        SocketAddress address = new InetSocketAddress(port);
        
        connection.connect(address);
        System.out.println("Server is now running at port " + port + ", waiting for connections.");
    }

     */
}
