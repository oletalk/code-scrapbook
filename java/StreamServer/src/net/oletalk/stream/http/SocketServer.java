/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.http;

import com.sun.net.httpserver.HttpServer;
import java.net.InetSocketAddress;
import java.util.concurrent.Executors;
import net.oletalk.stream.Populator;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

/**
 *
 * @author colin
 */
public class SocketServer {
    
    public static void main(String[] args) throws Exception
    {
        ApplicationContext applicationContext = new ClassPathXmlApplicationContext("/httpServerContext.xml");
        Handler handler = applicationContext.getBean("handler", Handler.class);
        
        
        HttpServer server = HttpServer.create(new InetSocketAddress(8081), 0);
        server.createContext("/", handler);
        server.setExecutor(Executors.newFixedThreadPool(3));
        
        server.start();
        System.out.println("Server is ready for connections.");
        
        Populator populator = applicationContext.getBean(Populator.class);
        populator.run();
        
    }


}
