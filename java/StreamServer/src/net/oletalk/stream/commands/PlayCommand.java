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

/**
 *
 * @author colin
 */
public class PlayCommand extends AbstractCommand {
    
    public PlayCommand(HttpExchange exchange, String rootdir)
    {
        super(exchange, rootdir);
    }
        
    @Override
    public void exec(Map<String, Object> args)  {
        
        String uri = (String)args.get("uri");
        SongList list = (SongList)args.get("list");
        boolean downsample = args.containsKey("downsample");

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
            
            if (song != null)
            {
                Header.setHeaders(exchange, Header.HeaderType.MUSIC);
                exchange.sendResponseHeaders(200, 0); // arbitrary amount - music

                try (OutputStream body = exchange.getResponseBody()) {
                if (downsample)
                {
                    LOG.log(Level.INFO, "Downsampling requested");
                    song.writeDownsampledStream(body);                        
                }
                else {
                    song.writeStream(body);                        
                }

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
