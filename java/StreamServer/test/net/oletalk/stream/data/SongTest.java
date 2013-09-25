/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.data;

import java.nio.file.Path;
import java.nio.file.Paths;
import net.oletalk.stream.actor.TagReader;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

/**
 *
 * @author colin
 */
public class SongTest {
    
    public SongTest() {
    }
    
    public static Song getTest1() {
        Path p = Paths.get("/test/path/song.mp3");
        Song instance = new Song(p);
        Tag tag = new Tag();
        tag.setFilepath(p);
        tag.setFilehash("3r328rifhsf");
        tag.setArtist("Us");
        tag.setTitle("A song");
        tag.setSecs(100);
        instance.setTag(tag);
        return instance;
    }
    
    public static Song getTest2() {
        Path p = Paths.get("/test/path/choon.mp3");
        Song instance = new Song(p);
        return instance;
    }

    public static Tag getTagTest2() {
        Tag tag = new Tag();
        tag.setFilehash("239r8iusddisuf");
        tag.setArtist("Us");
        tag.setTitle("A tune");
        tag.setSecs(112);
        return tag;
    }
    
    @BeforeClass
    public static void setUpClass() {
    }
    
    @AfterClass
    public static void tearDownClass() {
    }
    
    @Before
    public void setUp() {
    }
    
    @After
    public void tearDown() {
    }

    /**
     * Test of getTag method, of class Song.
     */
    @Test
    public void testGetTag() {
        System.out.println("getTag");
        Song instance = new Song(Paths.get("/test/path/song.mp3"));
        Tag tag = new Tag();
        tag.setTitle("A song");
        tag.setSecs(100);
        instance.setTag(tag);
        
        Tag expResult = new Tag();
        // the following should have the song copy its path to the tag.
        expResult.setFilepath(Paths.get("/test/path/song.mp3"));
        expResult.setTitle("A song");
        expResult.setSecs(100);
        Tag result = instance.getTag();
        assertTrue(expResult.equals(result));
    }

    /**
     * Test of getPath method, of class Song.
     */
    @Test
    public void testGetPath() {
        System.out.println("getPath");
        Song instance = new Song(Paths.get("/path/songs/shinynewsong.mp3"));
        Path expResult = Paths.get("/path/songs/shinynewsong.mp3");
        Path result = instance.getPath();
        assertEquals(expResult, result);
    }


    /**
     * Test of htmlValue method, of class Song.
     */
    @Test
    public void testHtmlValue() {
        System.out.println("htmlValue");
        Path rootpath = Paths.get("/test");
        Song instance = SongTest.getTest1();
        
        String expResult = "<a href=\"/s/play/path%2Fsong.mp3\">path/song.mp3<br/>\n";
        String result = instance.asHTML(rootpath);
        assertEquals(expResult, result);
    }

    /**
     * Test of m3uValue method, of class Song.
     */
    @Test
    public void testM3uValue() {
        System.out.println("m3uValue");
        String hostheader = "funkyhost:8081";
        Path rootpath = Paths.get("/test");
        Song instance = SongTest.getTest1();
        String expResult = "#EXTINF:100,Us - A song\nhttp://funkyhost:8081/s/play/path%2Fsong.mp3\n";
        String result = instance.m3uValue(hostheader, rootpath);
        assertEquals(expResult, result);
    }

    /**
     * Test of toString method, of class Song.
     */
    @Test
    public void testToString() {
        System.out.println("toString");
        Song instance = SongTest.getTest1();
        // not testing tag contents here.
        String expResult = "Song: /test/path/song.mp3\nwith Tag:" + instance.getTag().toString();
        String result = instance.toString();
        assertEquals(expResult, result);
    }

    /**
     * Test of getTagFromReader method, of class Song.
     */
    @Test
    public void testGetTagFromReader() {
        System.out.println("getTagFromReader");
        Song instance = SongTest.getTest2();
        // the following calls setTag() and tagreader.get(APath), so let's mock the latter
        TagReader tagreader = mock(TagReader.class);
        when(tagreader.get(instance.getPath())).thenReturn(SongTest.getTagTest2());
        
        instance.getTagFromReader(tagreader);
    }
}