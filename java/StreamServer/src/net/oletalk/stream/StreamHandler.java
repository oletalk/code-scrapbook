/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream;

import java.io.PrintStream;
import java.net.URLDecoder;
import java.util.logging.Level;
import java.util.logging.Logger;
import net.oletalk.stream.actor.Command;
import net.oletalk.stream.data.Song;
import net.oletalk.stream.data.SongList;
import net.oletalk.stream.util.Config;
import net.oletalk.stream.util.LogSetup;
import org.simpleframework.http.Request;
import org.simpleframework.http.Response;
import org.simpleframework.http.core.Container;

/**
 *
 * @author colin
 */
public class StreamHandler implements Container {
    
    private static final Logger LOG = LogSetup.getlog();
    
    private SongList list;
    
    private enum HeaderType { TEXT, MUSIC };
    
    public void setSongList(SongList list) 
    {
        this.list = list;
    }
    
    @Override
    public void handle (Request request, Response response)
    {
        try {
            PrintStream body = response.getPrintStream();
            long time = System.currentTimeMillis();
                        
            String uri = request.getPath().toString();
            if (uri != null && uri.startsWith("/"))
            {
                String[] cmdargs = uri.split("/", 3);
                String command = cmdargs[1];
                String path = cmdargs[2];
                
                // Unescape it
                path = URLDecoder.decode(path, "UTF-8");
                
                if (command != null)
                {
                    if (command.equals(Command.PLAY))
                    {
                        LOG.log(Level.FINE, "Received PLAY command");
                        // note: the rootdir should have a trailing slash here
                        String songreq = Config.get("rootdir") + path;
                        LOG.log(Level.FINE, "Going to request song {0}", songreq);
                        // check for it in the songlist
                        Song song = list.songFor(songreq);
                        // play it if so
                        if (song != null)
                        {
                            LOG.log(Level.INFO, "Playing song {0} ...", song.toString());
                            setHeaders(response, HeaderType.MUSIC);
                            song.writeStream(body);
                            body.close();
                            
                        } else {
                            LOG.log(Level.INFO, "Song {0} not found!", path.toString());
                            setHeaders(response, HeaderType.TEXT);
                            response.setDate("Date", time);
                            response.setDate("Last-Modified", time);
                            body.println("404 Not Found");
                            body.close();
                        }
                        
                    } else {
                        body.println("Hello World");
                        body.close();
                    }
                }
                
            }
            
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
