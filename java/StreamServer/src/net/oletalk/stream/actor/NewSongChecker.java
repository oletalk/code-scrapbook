/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.actor;

import java.nio.file.Path;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.Map;
import net.oletalk.stream.data.Song;

/**
 *
 * @author colin
 */
public class NewSongChecker extends SongCollector {

    public NewSongChecker(Map<Path, Song> songlist) {
        super(songlist);
    }
    
    @Override
    public boolean extraChecks(Path file, BasicFileAttributes attr)
    {
        if (attr.lastModifiedTime().toMillis() > baseline.getTime())
        {
            return true;
        }
        return false;
    }
}
