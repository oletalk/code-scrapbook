/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.actor;

import java.io.IOException;
import java.nio.file.FileVisitResult;
import java.nio.file.Path;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.Date;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import net.oletalk.stream.data.Song;
import net.oletalk.stream.util.LogSetup;

/**
 *
 * @author colin
 */
public class SongCollector extends SimpleFileVisitor<Path> {
    
    private final String SONGSPEC = "(?i).*\\.(mp3|ogg)";
    private Map<Path,Song> list;
    
    private static final Logger LOG = LogSetup.getlog();

    protected Date baseline;
    
    public SongCollector(Map<Path,Song> songlist)
    {
        list = songlist;
        baseline = new Date();
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
                
                if (!extraChecks(file, attr))
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
    
    public boolean extraChecks(Path file, BasicFileAttributes attr)
    {
        return true;
    }
}
