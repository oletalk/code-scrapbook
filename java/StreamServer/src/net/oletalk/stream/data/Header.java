/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.data;

import com.sun.net.httpserver.Headers;
import com.sun.net.httpserver.HttpExchange;

/**
 *
 * @author colin
 */
public class Header {
    
    public enum HeaderType { TEXT, HTML, MUSIC };

    public static void setHeaders( HttpExchange e, HeaderType h)
    {
        long time = System.currentTimeMillis();
        String timeString = new Long(time).toString();
                
        Headers headers = e.getResponseHeaders();
        headers.add("Date", timeString);
        headers.add("Last-Modified", timeString);

        switch (h) {
            case MUSIC:
                headers.add("Content-Type", "audio/x-mp3stream");
                headers.add("Cache-Control", "no-cache");
                headers.add("Pragma", "no-cache");
                headers.add("Connection", "close");
                headers.add("x-audiocast-name", "Streaming MP3S");
                break;
            case HTML:
                headers.add("Content-Type", "text/html");
                headers.add("Server", "StreamHandler/1.0 (Java1.6 HTTP)");
                break;
            default:
                headers.add("Content-Type", "text/plain");
                headers.add("Server", "StreamHandler/1.0 (Java1.6 HTTP)");
                break;
            
        }
    }
    

}
