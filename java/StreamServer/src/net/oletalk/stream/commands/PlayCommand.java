/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.commands;

import com.sun.net.httpserver.HttpExchange;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URLDecoder;
import java.util.logging.Level;
import net.oletalk.stream.actor.Downsampler;
import net.oletalk.stream.actor.StatsCollector;
import net.oletalk.stream.data.Header;
import net.oletalk.stream.data.Song;
import net.oletalk.stream.data.SongList;
import net.oletalk.stream.data.Tag;

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
    public void exec(Args args) {
        
        String uri = args.getUri();
        SongList list = args.getList();
        Integer buffersize = args.getBuffersize();
        Downsampler downsampler = null;
        if (args.isDownsample())
            downsampler = args.getDownsampler();
        StatsCollector sc = args.getCollector();
        boolean songStarted = false;
        boolean songWasInterrupted = false;
        
        try {
            long time = System.currentTimeMillis();

            // Unescape it
            String path = URLDecoder.decode(uri, "UTF-8");
            if (path != null && path.indexOf("/") != -1) {
                path = path.split("/")[0];
            }
            LOG.log(Level.FINE, "Received PLAY command");
            // note: the rootdir should have a trailing slash here
            String songreq = rootdir + path;
            LOG.log(Level.FINE, "Going to request song {0}", songreq);
            // check for it in the songlist
            //Song song = list.songFor(songreq);
            Song song = list.songById(path);
            // play it if so
            
            if (song != null)
            {
                Header.setHeaders(exchange, Header.HeaderType.MUSIC);
                exchange.sendResponseHeaders(200, 0); // arbitrary amount - music

                try (OutputStream body = exchange.getResponseBody()) {
                    songStarted = true;
                    song.writeStream(body, downsampler, buffersize); // 2nd arg null if no downsampling                        

                } catch (IOException ioe) {
                    String msg = ioe.getMessage();
                    if ("Broken pipe".equals(msg))
                    {
                        LOG.log(Level.INFO, "Playing song terminated early");
                        songWasInterrupted = true;
                    }
                }
                
                // if didn't terminate early, write the stats out
                if (sc != null && song.getTag() != null && songStarted && !songWasInterrupted)
                {
                    Tag t = song.getTag();
                    sc.countStat("ARTIST", t.getArtist());
                    sc.countStat("TITLE", t.getTitle());
                    LOG.log(Level.FINER, "Recorded 1 play for artist: ''{0}'', title: ''{1}.", 
                            new Object[]{t.getArtist(), t.getTitle()});
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
