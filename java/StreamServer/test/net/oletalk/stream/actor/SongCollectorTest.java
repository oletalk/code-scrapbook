/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.actor;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import net.oletalk.stream.data.InternalMap;
import org.junit.Test;
import static org.junit.Assert.*;
import org.junit.BeforeClass;

/**
 *
 * @author colin
 */
public class SongCollectorTest {
    
    public SongCollectorTest() {
    }

    @BeforeClass
    public static void setupClass() throws IOException
    {
        
    }
    
    @Test
    public void testCollectsSongs() throws IOException
    {
        
        Path tempDir = Files.createTempDirectory("tmp");
        Files.createTempFile(tempDir, "tmp", ".mp3");
        Path og1 = Files.createTempFile(tempDir, "tmp", ".ogG");
        Files.createTempFile(tempDir, "tmp", ".abc");
        Path tempSubDir = Files.createTempDirectory(tempDir, "tmp1");
        Files.createTempFile(tempSubDir, "tmp1", ".mp3");
        //System.out.println("tempDir = " + tempDir.toString());
        //System.out.println("mp31 = " + mp31.toString());
        tempDir.toFile().deleteOnExit();
        
        InternalMap songlist = new InternalMap();
        SongCollector instance = new SongCollector(songlist);
        
        Files.walkFileTree(tempDir, instance);
        
        assertEquals(3, songlist.size());
        assertTrue(songlist.get(og1).toString().endsWith(".ogG"));
        
    }
    
}