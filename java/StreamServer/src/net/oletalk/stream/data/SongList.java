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
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author colin
 */
public class SongList extends SimpleFileVisitor<Path> {
    
    private List<Song> list;
    
    public void initList(String initialDir) throws IOException
    {
        Path initialPath = Paths.get(initialDir);
        list = new ArrayList<>();
        Files.walkFileTree(initialPath, this);
    }
    
    @Override
    public String toString()
    {
        StringBuilder ret = new StringBuilder("SongList:");
        for (Song s : list) 
        {
            ret.append(s.toString()).append("\n");
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
                {
                    addfile = false;
                }
                                
                if (!filename.matches("(?i).*\\.(mp3|ogg)"))
                {
                    System.out.println("File '" + filename + "' doesn't match regex!");
                    addfile = false;
                }
            }
            
            if (addfile)
            {
                list.add(new Song(file));
            }
        }
        return FileVisitResult.CONTINUE;
    }
    
    @Override
    public FileVisitResult visitFileFailed(Path file, IOException exc)
    {
        System.err.println(exc);
        return FileVisitResult.CONTINUE;
    }
}
