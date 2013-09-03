/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.commands;

import com.sun.net.httpserver.HttpExchange;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;
import java.net.URLDecoder;
import java.util.Map;
import java.util.logging.Level;
import net.oletalk.stream.data.Header;
import net.oletalk.stream.data.Song;
import net.oletalk.stream.data.SongList;
import org.simpleframework.http.Response;

/**
 *
 * @author colin
 */
public class PlayCommand extends AbstractCommand {

    public PlayCommand(Response response, String rootdir) {
        super(response, rootdir);
    }
    
    public PlayCommand(HttpExchange exchange, String rootdir)
    {
        super(exchange, rootdir);
    }
        
    @Override
    public void exec(Map<String, Object> args)  {
        
        String uri = (String)args.get("uri");
        SongList list = (SongList)args.get("list");
        
        try {
            long time = System.currentTimeMillis();

            // Unescape it
            String path = URLDecoder.decode(uri, "UTF-8");

            LOG.log(Level.FINE, "Received PLAY command");
            // note: the rootdir should have a trailing slash here
            String songreq = rootdir + path;
            LOG.log(Level.FINE, "Going to request song {0}", songreq);
            // check for it in the songlist
            Song song = list.songFor(songreq);
            // play it if so
            
            if (exchange == null)
            {
                PrintStream body = response.getPrintStream();
                if (song != null)
                {

                    LOG.log(Level.FINE, "Playing song {0} ...", song.toString());
                    Header.setHeaders(response, Header.HeaderType.MUSIC);
                    song.writeStream(body);
                    //song.writeDownsampledStream(body);

                } else {
                    LOG.log(Level.WARNING, "Song {0} not found!", path.toString());
                    Header.setHeaders(response, Header.HeaderType.TEXT);
                    response.setDate("Date", time);
                    response.setDate("Last-Modified", time);
                    response.setCode(404);
                    body.println("404 Not Found");
                }
                response.close();
                
            } else {
                if (song != null)
                {
                    Header.setHeaders(exchange, Header.HeaderType.MUSIC);
                    exchange.sendResponseHeaders(200, 0); // arbitrary amount - music

                    try (OutputStream body = exchange.getResponseBody()) {
                        song.writeStream(body);
                    }
                } else {
                    LOG.log(Level.WARNING, "Song {0} not found!", path.toString());
                    Header.setHeaders(exchange, Header.HeaderType.TEXT);
                    String str = "404 Not Found";
                    exchange.sendResponseHeaders(404, str.length());
                    
                    try (OutputStream body = exchange.getResponseBody()) {
                        body.write(str.getBytes());
                    }
                }
            }
        } catch (IOException ex) {
            String msg = ex.getMessage();
            if ("Broken pipe".equals(msg))
            {
                LOG.log(Level.INFO, "Playing song terminated early");
            }
            else {
                LOG.log(Level.SEVERE, "Exception caught while playing song", ex);                
            }
        }

    }
    
}
