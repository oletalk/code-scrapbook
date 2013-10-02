/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.actor;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import net.oletalk.stream.data.InternalMap;
import org.junit.BeforeClass;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 *
 * @author colin
 */
public class NewSongCheckerTest {
    
    public NewSongCheckerTest() {
    }
    
    @BeforeClass
    public static void setUpClass() {
    }
    
    @Test
    public void testCollectsNewSongs() throws IOException, InterruptedException {
        Path tempDir = Files.createTempDirectory("tmp");
        Files.createTempFile(tempDir, "tmp", ".mp3");
        Path og1 = Files.createTempFile(tempDir, "tmp", ".ogG");
        Files.createTempFile(tempDir, "tmp", ".abc");
        //System.out.println("tempDir = " + tempDir.toString());
        //System.out.println("mp31 = " + mp31.toString());
        tempDir.toFile().deleteOnExit();
        
        // Collect the initial list first
        InternalMap songlist = new InternalMap();
        SongCollector collector = new SongCollector(songlist);
        
        Files.walkFileTree(tempDir, collector);
        
        assertEquals(2, songlist.size());
        assertTrue(songlist.get(og1).toString().endsWith(".ogG")); // initial collect

        // create new-song-checker instance
        NewSongChecker instance = new NewSongChecker(songlist);
        instance.setBaseline();
        Thread.sleep(1000);
        // now create some new files and attempt to pick them up
        Path og2 = Files.createTempFile(tempDir, "tmp", ".OGG");
        Files.createTempFile(tempDir, "tmp", ".wav");
        Files.createTempFile(tempDir, "tmp", ".mp3");
        
        Files.walkFileTree(tempDir, instance);
        
        assertEquals(4, songlist.size());
        assertTrue(songlist.get(og2).toString().endsWith(".OGG"));
        
        // create a non-song file and see if it picks it up too
        Files.createTempFile(tempDir, "tmp", ".abc");
        Files.walkFileTree(tempDir, instance);
        
        assertEquals(4, songlist.size());

    }


}