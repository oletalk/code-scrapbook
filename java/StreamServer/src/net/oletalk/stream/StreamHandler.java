/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream;

import java.io.PrintStream;
import java.util.logging.Level;
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
    
    private enum HeaderType { TEXT, MUSIC };
            
    @Override
    public void handle (Request request, Response response)
    {
        try {
            PrintStream body = response.getPrintStream();
            long time = System.currentTimeMillis();
            
            setHeaders(response, HeaderType.TEXT);
            response.setDate("Date", time);
            response.setDate("Last-Modified", time);
            
            String uri = request.getPath().toString();
            if (uri != null && uri.startsWith("/"))
            {
                String[] cmdargs = uri.split("/", 3);
                String command = cmdargs[1];
                String path = cmdargs[2];
            }
            
            body.println("Hello World");
            body.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private void setHeaders( Response r, HeaderType h ) 
    {
        switch (h) {
            case MUSIC:
                r.setValue("Content-Type", "audio/x-mp3stream");
                r.setValue("Cache-Control", "no-cache");
                r.setValue("Pragma", "no-cache");
                r.setValue("Connection", "close");
                r.setValue("x-audiocast-name", "Streaming MP3S");
                break;
            default:
                r.setValue("Content-Type", "text/plain");
                r.setValue("Server", "StreamHandler/1.0 (Simple 5.1.4)");
                break;
        }
    }
}
