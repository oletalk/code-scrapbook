/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream;

import java.util.logging.Level;
import java.util.logging.Logger;
import net.oletalk.stream.data.SongList;
import net.oletalk.stream.util.LogSetup;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;
import org.springframework.core.env.Environment;

/**
 *
 * @author colin
 */
public class Scrap {
    
    private static final Logger LOG = LogSetup.getlog();
    
    public static void main(String[] args) throws Exception
    {
        // Start up
        ApplicationContext applicationContext = new ClassPathXmlApplicationContext("/streamserverContext.xml");

        Environment env = applicationContext.getEnvironment();

        LOG.setLevel(Level.FINER);
        
        SongList songlist = new SongList();
        songlist.initList(env.getProperty("rootdir"));
        System.out.println("Done reading song list.  " + songlist.numberOfSongs() + " song(s) read.");
        
        // TODO: you may have duplicate mp3s in your list.  What happens then??
        
        
        //Path p = Paths.get("/Volumes/rockport/mp3/ripped/Sneaker Pimps - Velvet Divorce.mp3");
        //Tag t = TagReader.get(p);
        //System.out.println(t);
    }
}
