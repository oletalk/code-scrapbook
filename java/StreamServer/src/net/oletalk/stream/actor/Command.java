/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.actor;

import java.io.PrintStream;
import java.net.URLDecoder;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.logging.Level;
import java.util.logging.Logger;
import net.oletalk.stream.Header;
import net.oletalk.stream.data.Song;
import net.oletalk.stream.data.SongList;
import net.oletalk.stream.util.Config;
import net.oletalk.stream.util.LogSetup;
import net.oletalk.stream.util.TagReader;
import org.simpleframework.http.Response;

/**
 *
 * @author colin
 */
public class Command {

    public static final String PLAY = "play";
    public static final String LIST = "list";
    public static final String DROP = "drop";
    
    private static final Logger LOG = LogSetup.getlog();

    private Response response;
    
    public Command(Response response)
    {
        this.response = response;
    }
    
    public void doDefault() throws Exception
    {
        try (PrintStream body = response.getPrintStream()) {
            long time = System.currentTimeMillis();

            Header.setHeaders(response, Header.HeaderType.TEXT);
            response.setDate("Date", time);
            response.setDate("Last-Modified", time);
            body.println("400 Bad Request");
        }

    }
    
    public void list(SongList list, String uri) throws Exception
    {
        // Unescape it
        String path = uri;
        try (PrintStream body = response.getPrintStream()) {
            long time = System.currentTimeMillis();

            // TODO: Use paths to figure out which files are below the given URI
            String pathreq = Config.get("rootdir") + path;
            Path listdir = Paths.get(pathreq);
            LOG.log(Level.FINE, "Received LIST command");
            
            String html = list.HTMLforList(listdir);
            
            Header.setHeaders(response, Header.HeaderType.HTML);
            response.setDate("Date", time);
            response.setDate("Last-Modified", time);
            body.println(html);
        }

    }
    
    // TODO: drop doesn't really need a URI unless you want a partial playlist, maybe?
    public void drop(SongList list, String uri) throws Exception
    {
        PrintStream body = response.getPrintStream();
        String path = uri;
        long time = System.currentTimeMillis();

        String pathreq = Config.get("rootdir") + path;
        Path listdir = Paths.get(pathreq);
        LOG.log(Level.FINE, "Received DROP command");

        String html = list.M3UforList(listdir);

        Header.setHeaders(response, Header.HeaderType.HTML);
        response.setDate("Date", time);
        response.setDate("Last-Modified", time);
        body.println(html);

    }
    
    public void play(SongList list, String uri) throws Exception 
    {
        PrintStream body = response.getPrintStream();
        long time = System.currentTimeMillis();
                
        // Unescape it
        String path = URLDecoder.decode(uri, "UTF-8");
        
        LOG.log(Level.FINE, "Received PLAY command");
        // note: the rootdir should have a trailing slash here
        String songreq = Config.get("rootdir") + path;
        LOG.log(Level.FINE, "Going to request song {0}", songreq);
        // check for it in the songlist
        Song song = list.songFor(songreq);
        // play it if so
        if (song != null)
        {
            // TODO: is this the best place to populate the tag? Probably not
            if (song.getTag() == null)
            {
                LOG.log(Level.INFO, "Trying to populate empty tag...");
                song.populateTag();
            }
            
            LOG.log(Level.FINE, "Playing song {0} ...", song.toString());
            Header.setHeaders(response, Header.HeaderType.MUSIC);
            song.writeStream(body);
            body.close();

        } else {
            LOG.log(Level.WARNING, "Song {0} not found!", path.toString());
            Header.setHeaders(response, Header.HeaderType.TEXT);
            response.setDate("Date", time);
            response.setDate("Last-Modified", time);
            response.setCode(404);
            body.println("404 Not Found");
            body.close();
        }

    }
    
}
