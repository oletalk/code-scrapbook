/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.http;

import net.oletalk.stream.handler.StreamHandler;
import net.oletalk.stream.handler.RenderHandler;
import net.oletalk.stream.Populator;
import net.oletalk.stream.actor.Wrapper;
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
        //Handler handler = applicationContext.getBean("handler", Handler.class);
        
        Wrapper wrapper = applicationContext.getBean(Wrapper.class);
        //server.createContext("/", handler);

        wrapper.addHandler("/s", applicationContext.getBean(StreamHandler.class));
        wrapper.addHandler("/r", applicationContext.getBean(RenderHandler.class));
        
        wrapper.start();
        
        Populator populator = applicationContext.getBean(Populator.class);
        populator.run();
        
    }


}
