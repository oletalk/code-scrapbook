/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream;

import java.util.Random;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;
import net.oletalk.stream.data.Song;
import net.oletalk.stream.data.SongList;
import net.oletalk.stream.util.LogSetup;
import net.oletalk.stream.util.Util;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;

/**
 *
 * @author colin
 */
public class Populator implements Runnable {
    
    private static final Logger LOG = LogSetup.getlog();
     
    @Autowired
    private SongList songlist;
    
    private @Value("${pausesecs}") int pauseSecs;
    

    @Override
    public void run() {

        Random randomGenerator = new Random();
        
        while (true) 
        {
            // get a song which doesn't have a tag
            
            // TODO: What if the tagging library can't find the song?  How do we let it know to give up?
            //       What if there's a more transient error?  Should be fine to keep searching then.
            
            LOG.log(Level.INFO, "Checking untagged songs");
            Set<Song> uss = songlist.getUntaggedSongs();
            
            if (uss.size() > 0) 
            {
                Song[] untaggedsongs = uss.toArray(new Song[uss.size()]);
                Song song = untaggedsongs[randomGenerator.nextInt(uss.size())];
                if (song.getTag() == null)
                {
                    LOG.log(Level.INFO, "Trying to populate empty tag...");
                    songlist.populateTag(song);
                }
                
            }
            else { 
                // (what if the songs all (currently) have tags?? sleep for a long time? exit?)
                Util.sleep(pauseSecs * 100);
            }
            
            // also check if it's time to regenerate the songlist
            if (songlist.isStale())
            {
                LOG.log(Level.INFO, "Songlist is now stale! Trying to regenerate it now.");
                synchronized (this) {
                    songlist.checkForNewSongs();
                }
            }
            
            // and sleep
            Util.sleep(pauseSecs);
        }
    }
}

   //        songlist.populateAllTags(10);
      //  System.exit(0);
        // 20/08/2013
        // TODO: possibly use this class to background(??)-populate song tags in the db
        // TODO: you may have duplicate mp3s in your list.  What happens then??
        
        //Path p = Paths.get("/Volumes/rockport/mp3/ripped/Sneaker Pimps - Velvet Divorce.mp3");
        //Tag t = TagReader.get(p);
        //System.out.println(t);
    //}
