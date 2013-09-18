/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.actor;

import java.io.File;
import java.io.IOException;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.attribute.BasicFileAttributes;
import java.nio.file.spi.FileSystemProvider;
import java.util.HashMap;
import net.oletalk.stream.data.Song;
import org.junit.Test;
import static org.junit.Assert.*;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
/**
 *
 * @author colin
 */
public class SongCollectorTest {
    
    public SongCollectorTest() {
    }
    
    private void putSong(String path, HashMap<Path,Song> songs)
    {
        Path p = Paths.get(path);
        songs.put(p, new Song(p));
    }

    @Test
    public void testCollection() throws IOException {
        System.out.println("collecting files");
        HashMap<Path,Song> hm = new HashMap<>();
        SongCollector instance = new SongCollector(hm);
        
        // Setup expected song list
        HashMap<Path,Song> expected = new HashMap<>();
        putSong("/root/first.mp3", expected);
        putSong("/root/sec ond.mp3", expected);
        putSong("/root/abc.mp3", expected);
        
        
        //        Files.walkFileTree(initialPath, sc);
        // Setup mock directory for walking the tree
        Path rootDir = newMockFile( "root", true);
        Path firstMp3 = newMockFile( "first.mp3" );
        Path secondMp3 = newMockFile( "sec ond.mp3" );
        Path thirdMp3 = newMockFile( "abc.mp3" );
        Path notanMp3 = newMockFile( "test.txt" );
        //when( rootDir. ).thenReturn( new File[] { firstMp3, secondMp3, thirdMp3, notanMp3 } );

        Files.walkFileTree(rootDir, instance);
    }
    /**
     * Test of visitFile method, of class SongCollector.
     */
    @Test
    public void testVisitFile() {
        System.out.println("visitFile");
        Path file = null;
        BasicFileAttributes attr = null;
        SongCollector instance = null;
        FileVisitResult expResult = null;
        FileVisitResult result = instance.visitFile(file, attr);
        assertEquals(expResult, result);
        // TODO review the generated test code and remove the default call to fail.
        fail("The test case is a prototype.");
    }

    /**
     * Test of visitFileFailed method, of class SongCollector.
     */
    @Test
    public void testVisitFileFailed() {
        System.out.println("visitFileFailed");
        Path file = null;
        IOException exc = null;
        SongCollector instance = null;
        FileVisitResult expResult = null;
        FileVisitResult result = instance.visitFileFailed(file, exc);
        assertEquals(expResult, result);
        // TODO review the generated test code and remove the default call to fail.
        fail("The test case is a prototype.");
    }

    /**
     * Test of extraChecks method, of class SongCollector.
     */
    @Test
    public void testExtraChecks() {
        System.out.println("extraChecks");
        Path file = null;
        BasicFileAttributes attr = null;
        SongCollector instance = null;
        boolean expResult = false;
        boolean result = instance.extraChecks(file, attr);
        assertEquals(expResult, result);
        // TODO review the generated test code and remove the default call to fail.
        fail("The test case is a prototype.");
    }

    

}