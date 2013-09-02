/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.commands;

import com.sun.net.httpserver.HttpExchange;
import java.io.IOException;
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
        
        try (PrintStream body = response.getPrintStream()) {
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
        } catch (IOException ex) {
            LOG.log(Level.SEVERE, "Exception caught while playing song", ex);
        }

    }
    
}
