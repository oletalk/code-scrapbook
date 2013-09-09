/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.data;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.annotation.PostConstruct;
import net.oletalk.stream.actor.SongCollector;
import net.oletalk.stream.util.LogSetup;
import net.oletalk.stream.util.Stopwatch;
import net.oletalk.stream.actor.TagReader;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;

/**
 *
 * @author colin
 */
public class SongList  {
    
    private static final Logger LOG = LogSetup.getlog();

    private Map<Path,Song> list;
    
    @Autowired
    private TagReader tagreader;
    
    private @Value("${downsampling:on}") boolean downsamplingEnabled;
    private @Value("${rootdir}") String initialDir;
    private Map<Song,String> untaggedsongs = new ConcurrentHashMap<>();
    
    @PostConstruct
    public void initList() throws IOException
    {
        Path initialPath = Paths.get(initialDir);
        list = new TreeMap<>();

        Stopwatch s = new Stopwatch(true);
        
        SongCollector sc = new SongCollector(list);
        Files.walkFileTree(initialPath, sc);
        
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
        int listsize = list.size();
        LOG.log(Level.CONFIG, "Loaded {0} song(s) in {1} in {2} ms.", 
                new Object[]{listsize, initialDir, s.elapsedTime()});
        
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
    
    public String HTMLforList (Path path) throws UnsupportedEncodingException
    {
        StringBuilder ret = new StringBuilder();
        List<Song> songs = songsUnder(path);
        for (Song song : songs)
        {
            ret.append(song.htmlValue(path));
        }
        
        String str = new String(ret.toString().getBytes("UTF8"));
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
