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
import java.util.TreeMap;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.annotation.PostConstruct;
import net.oletalk.stream.actor.SongCollector;
import net.oletalk.stream.util.LogSetup;
import net.oletalk.stream.util.Stopwatch;
import net.oletalk.stream.util.TagReader;
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
    
    private @Value("${rootdir}") String initialDir;
    
    @PostConstruct
    public void initList() throws IOException
    {
        Path initialPath = Paths.get(initialDir);
        list = new TreeMap<>();

        Stopwatch s = new Stopwatch(true);
        
        SongCollector sc = new SongCollector(list);
        Files.walkFileTree(initialPath, sc);
        int listsize = list.size();
        LOG.log(Level.CONFIG, "Loaded {0} song(s) in {1} in {2} ms.", 
                new Object[]{listsize, initialDir, s.elapsedTime()});
        
    }
    
    
    public void populateTag(Song song)
    {
        song.getTagFromReader(tagreader);
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
            String st = song.pathFrom(path);
            // paths with accents in them don't work
            String st_enc = URLEncoder.encode(st);

            ret.append("<a href=\"/play/").append(st_enc).append("\">").append(st).append("<br/>\n");
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
    


    public String M3UforList(Path listdir) throws UnsupportedEncodingException {
        StringBuilder ret = new StringBuilder();
        List<Song> songs = songsUnder(listdir);
        for (Song song : songs)
        {
            ret.append(song.htmlValue(listdir));
        }
        
        String str = new String(ret.toString().getBytes("UTF8"));
        return str;
    }
}
