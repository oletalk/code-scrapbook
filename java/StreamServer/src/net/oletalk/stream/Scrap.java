/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.logging.Level;
import java.util.logging.Logger;
import net.oletalk.stream.data.SongList;
import net.oletalk.stream.data.Tag;
import net.oletalk.stream.util.Config;
import net.oletalk.stream.util.LogSetup;
import net.oletalk.stream.util.TagReader;

/**
 *
 * @author colin
 */
public class Scrap {
    
    private static final Logger LOG = LogSetup.getlog();
    
    public static void main(String[] args) throws Exception
    {
        // Start up
        Config.init();

        LOG.setLevel(Level.FINER);
        
        SongList songlist = new SongList();
        songlist.initList(Config.get("rootdir"));
        System.out.println("Done reading song list.  " + songlist.numberOfSongs() + " song(s) read.");
        
        // TODO: you may have duplicate mp3s in your list.  What happens then??
        
        
        //Path p = Paths.get("/Volumes/rockport/mp3/ripped/Sneaker Pimps - Velvet Divorce.mp3");
        //Tag t = TagReader.get(p);
        //System.out.println(t);
    }
}
