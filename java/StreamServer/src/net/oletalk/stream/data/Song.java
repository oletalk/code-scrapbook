/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.data;

import java.nio.file.Path;

/**
 *
 * @author colin
 */
public class Song {
    
    private Path path;
    
    public Song (Path path)
    {
        this.path = path;
    }
    
    @Override
    public String toString()
    {
        return "Song: " + path.toString();
    }
}
