/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.http;

import com.sun.net.httpserver.HttpServer;
import java.net.InetSocketAddress;
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
        server.setExecutor(null);
        server.start();
        
    }


}
