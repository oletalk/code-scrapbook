/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream;

import org.simpleframework.http.Response;

/**
 *
 * @author colin
 */
public class Header {
    
    public enum HeaderType { TEXT, HTML, MUSIC };

    public static void setHeaders( Response r, HeaderType h ) 
    {
        switch (h) {
            case MUSIC:
                r.setValue("Content-Type", "audio/x-mp3stream");
                r.setValue("Cache-Control", "no-cache");
                r.setValue("Pragma", "no-cache");
                r.setValue("Connection", "close");
                r.setValue("x-audiocast-name", "Streaming MP3S");
                break;
            case HTML:
                r.setValue("Content-Type", "text/html");
                r.setValue("Server", "StreamHandler/1.0 (Simple 5.1.4)");
                break;
            default:
                r.setValue("Content-Type", "text/plain");
                r.setValue("Server", "StreamHandler/1.0 (Simple 5.1.4)");
                break;
        }
    }

}
