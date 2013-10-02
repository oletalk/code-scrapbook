/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.data;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.annotation.PostConstruct;
import net.oletalk.stream.actor.NewSongChecker;
import net.oletalk.stream.actor.SongCollector;
import net.oletalk.stream.util.LogSetup;
import net.oletalk.stream.util.Stopwatch;
import net.oletalk.stream.actor.TagReader;
import net.oletalk.stream.interfaces.HTMLRepresentable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;

/**
 *
 * @author colin
 */
public class SongList implements HTMLRepresentable {
    
    private static final Logger LOG = LogSetup.getlog();

    private InternalMap list;
    
    @Autowired
    private TagReader tagreader;
    
    private @Value("${updatemins}") String updateMins;
    private @Value("${downsampling:on}") boolean downsamplingEnabled;
    private @Value("${rootdir}") String initialDir;
    private Map<Song,String> untaggedsongs = new ConcurrentHashMap<>();
    
    private int updateSecs = 0;
    private Date lastUpdated;
    private Date lastChecked;
    
    @PostConstruct
    public void initList() throws IOException
    {
        Path initialPath = Paths.get(initialDir);
        list = new InternalMap();

        try {
            updateSecs = Integer.parseInt(updateMins);
            updateSecs *= 60;
        } catch (NumberFormatException nfe) {
            LOG.log(Level.INFO, "Unable to parse number of minutes to update the songlist from '{0}'", updateMins);
        }
        
        Stopwatch s = new Stopwatch(true);
        
        SongCollector sc = new SongCollector(list);
        Files.walkFileTree(initialPath, sc);
        if (this.hasNoSongs()) 
        {
            System.err.println("NO SONGS FOUND!");
            System.exit(1);
        }
        checkSongsForTags();
        int listsize = list.size();
        LOG.log(Level.CONFIG, "Loaded {0} song(s) in {1} in {2} ms.", 
                new Object[]{listsize, initialDir, s.elapsedTime()});
        lastUpdated = new Date();
        lastChecked = new Date();
        
    }
        
    public void checkForNewSongs()
    {
        lastChecked = new Date();
        
        InternalMap newsongs = new InternalMap();
        NewSongChecker nsc = new NewSongChecker(newsongs);
        
        if (!newsongs.isEmpty())
        {
            LOG.log(Level.INFO, "Found {0} new song(s).", newsongs.size());
            list.putAll(newsongs);
            checkSongsForTags();
            lastUpdated = new Date();
        }
    }
    
    private void checkSongsForTags()
    {
        for (Song song : list.values())
        {
            // does the song already have a tag in the database?
            Path p = song.getPath();
            Tag tag = tagreader.getFromDB(p);
            if (tag != null) {
                song.setTag(tag);
            }
            else {
                LOG.log(Level.INFO, "Song {0} doesn''t yet have a tag in the database.", p.toString());
                addUntaggedSong(song);                
            }
        }        
    }

    public boolean isStale()
    {
        boolean ret = false;
        Date now = new Date();
        
        if (updateSecs > 0)
        {
            long diff = (now.getTime() - lastChecked.getTime());
            if (diff > (updateSecs * 1000))
            {
                ret = true;
            }
        }
        return ret;
    }
    
    /**
     * Extracts MP3 tag information for all the songs in the SongList.
     * This takes VERY LONG, so best to call this offline
     * @param notifyEvery 
     */
    public void populateAllTags(int notifyEvery)
    {
        int ctr = 0;
        int total = list.size();
        Stopwatch sw = new Stopwatch(true);
        for (Song s : list.values())
        {
            ctr++;
            if (ctr % notifyEvery == 0)
            {
                LOG.log(Level.INFO, "{0} out of {1} songs tagged.", new Object[]{ctr, total});
            }
            populateTag(s);
        }
        LOG.log(Level.INFO, "Operation completed in {0} ms.", sw.elapsedTime());
    }
    
    public void addUntaggedSong(Song song)
    {
        untaggedsongs.put(song, "1");
    }
    
    public void populateTag(Song song)
    {
        song.getTagFromReader(tagreader);
        if (song.getTag() != null)
        {
            untaggedsongs.remove(song);
        }
    }
    
    /**
     * Returns a random untagged song
     * @return 
     */
    public Set<Song> getUntaggedSongs()
    {
        return untaggedsongs.keySet();
    }
    
    public boolean contains(String songreq)
    {
        boolean ret = false;
        Path p = Paths.get(songreq);
        if (p != null)
        {
            ret = (list.containsKey(p));
        } else {
            LOG.warning("Requested path returned a null result");
        }
        
        return ret;
    }
    
    public int numberOfSongs()
    {
        if (list != null)
        {
            return list.size();
        }
        else {
            throw new IllegalStateException("SongList not yet initialised");
        }
    }
    
    @Override
    public String asHTML (Path path)
    {
        StringBuilder ret = new StringBuilder();
        List<Song> songs = songsUnder(path);
        for (Song song : songs)
        {
            ret.append(song.asHTML(path));
        }
        
        String str = "Problem with UTF8 encoding!";
        try {
            str = new String(ret.toString().getBytes("UTF8"));
        } catch (UnsupportedEncodingException ex) {
            LOG.log(Level.SEVERE, "Problems with UTF8 encoding", ex);
        }
        return str;
    }
    
    public String M3UforList(Path listdir, String hostheader) throws UnsupportedEncodingException {
        StringBuilder ret = new StringBuilder();
        List<Song> songs = songsUnder(listdir);
        
        LOG.log(Level.FINE, "Songs found for M3U list: {0}", songs.size());
        
        boolean firstSong = true;
        for (Song song : songs)
        {
            if (firstSong) {
                ret.append("#EXTM3U\n");
                firstSong = false;
            }
            ret.append(song.m3uValue(hostheader, listdir));
        }
        
        String str = new String(ret.toString().getBytes("UTF8"));
        return str;
    }

    private List<Song> songsUnder(Path path)
    {
        List<Song> ret = new ArrayList<>();
        for (Path songpath : list.keySet())
        {
            if (songpath.startsWith(path))
            {
                ret.add(list.get(songpath));
            }
        }
        return ret;
    }
    
    public Song songById(String songreq)
    {
        long sid;
        try {
            sid = Long.parseLong(songreq); 
        } catch (NumberFormatException nfe) {
            LOG.log(Level.WARNING, "Couldn't parse long given input", nfe);
            return null;
        }
        return list.getById(sid);
        
    }
    
    public Song songFor(String songreq)
    {
        Song ret = null;
        Path p = Paths.get(songreq);
        if (p != null) 
        {
            ret = list.get(p);
        } else {
            LOG.warning("Requested path returned a null result");
        }
        return ret;
    }
    
    @Override
    public String toString()
    {
        StringBuilder ret = new StringBuilder("SongList:");
        for (Path p : list.keySet()) 
        {
            ret.append(p.toString()).append("\n");
        }
        return ret.toString();
    }
    
    public boolean hasNoSongs() {
        return (list.isEmpty());
    }
}
