/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream;

import java.io.IOException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

/**
 *
 * @author colin
 */
public class Launcher {
    
    public static void main(String[] args) throws IOException {
        // Bootstrap
        ApplicationContext applicationContext = new ClassPathXmlApplicationContext("/streamserverContext.xml");
        StreamServer ssrvr = applicationContext.getBean("server", StreamServer.class);
        ssrvr.startup();
    }
}
