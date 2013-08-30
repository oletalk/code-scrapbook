/*
 * A streaming MP3 server which uses the Spring and Simple frameworks.
 */
package net.oletalk.stream;

import java.io.IOException;
import java.net.SocketAddress;
import java.util.logging.Level;
import java.util.logging.Logger;
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
}
