/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream;

import java.io.PrintStream;
import java.util.logging.Logger;
import net.oletalk.stream.util.LogSetup;
import org.simpleframework.http.Request;
import org.simpleframework.http.Response;
import org.simpleframework.http.core.Container;

/**
 *
 * @author colin
 */
public class StreamHandler implements Container {
    
    private static final Logger LOG = LogSetup.newlog();
    
    @Override
    public void handle (Request request, Response response)
    {
        try {
            PrintStream body = response.getPrintStream();
            long time = System.currentTimeMillis();
            
            response.setValue("Content-Type", "text/plain");
            response.setValue("Server", "StreamHandler/1.0 (Simple 5.1.4)");
            response.setDate("Date", time);
            response.setDate("Last-Modified", time);
            
            LOG.info("Request is " + request.toString());
            //System.out.println("Request is " + request.toString());
            body.println("Hello World");
            body.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
