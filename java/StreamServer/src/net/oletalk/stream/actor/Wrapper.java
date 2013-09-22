/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.actor;

import com.sun.net.httpserver.HttpServer;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.util.concurrent.Executors;
import javax.annotation.PostConstruct;
import net.oletalk.stream.handler.GeneralHandler;
import org.springframework.beans.factory.annotation.Value;

/**
 *
 * @author colin
 */
public class Wrapper {
    
    public static final int NUM_THREADS = 5;
    
    private HttpServer server;
    private int port;
    private boolean started;
    
    public Wrapper(int port) throws IOException
    {
        this.port = port;
        server = HttpServer.create(new InetSocketAddress(port), 0);
    }
        
    public void addHandler(String context, GeneralHandler handler)
    {
        server.createContext(context, handler);
    }
    
    public void removeHandler(String context)
    {
        server.removeContext(context);
    }
    
    public void start()
    {
        if (!started) {
            server.setExecutor(Executors.newFixedThreadPool(NUM_THREADS));
            server.start();
            System.out.println("Server is ready for connections on port " + port);
        } else {
            System.err.println("Server ALREADY STARTED");
        }
    }
    
    public HttpServer getServer()
    {
        return server;
    }
}
