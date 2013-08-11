/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.data;

import java.io.IOException;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.Map;
import java.util.TreeMap;
import java.util.logging.Level;
import java.util.logging.Logger;
import net.oletalk.stream.util.LogSetup;
import net.oletalk.stream.util.Stopwatch;

/**
 *
 * @author colin
 */
public class SongList extends SimpleFileVisitor<Path> {
    
    private final String SONGSPEC = "(?i).*\\.(mp3|ogg)";
    private static final Logger LOG = LogSetup.getlog();

    private Map<Path,Song> list;
    
    public void initList(String initialDir) throws IOException
    {
        Path initialPath = Paths.get(initialDir);
        list = new TreeMap<>();

        Stopwatch s = new Stopwatch(true);
        Files.walkFileTree(initialPath, this);
        LOG.log(Level.CONFIG, "Loaded all songs in {0} in {1} ms.", 
                new Object[]{initialDir, s.elapsedTime()});
        
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
    
    // - File visitor methods
    @Override
    public FileVisitResult visitFile(Path file, BasicFileAttributes attr)
    {
        if (attr.isRegularFile())
        {
            boolean addfile = true;
            // check for OGG/MP3, and we don't want any of those "._funny" files
            Path name = file.getFileName();
            if (name != null)
            {
                String filename = name.toString();
                if (filename.startsWith("."))
                    addfile = false;
                                
                if (!filename.matches(SONGSPEC))
                    addfile = false;
            }
            
            if (addfile)
            {
                list.put(file, new Song(file));
            }
        }
        return FileVisitResult.CONTINUE;
    }
    
    @Override
    public FileVisitResult visitFileFailed(Path file, IOException exc)
    {
        LOG.log(Level.WARNING, "Problem with file {0}: {1}", 
                new Object[]{file.toString(), exc.toString()});
        return FileVisitResult.CONTINUE;
    }
}
