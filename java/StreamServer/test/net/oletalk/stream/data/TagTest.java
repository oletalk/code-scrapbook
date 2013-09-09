/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.data;

import java.nio.file.Path;
import java.nio.file.Paths;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 *
 * @author colin
 */
public class TagTest {
    
    public TagTest() {
    }

    /**
     * Test of getFilepath method, of class Tag.
     */
    @Test
    public void testGetFilepath() {
        System.out.println("getFilepath");
        Tag instance = new Tag();
        instance.setFilepath(Paths.get("/some/path"));
        Path expResult = Paths.get("/some/path");
        Path result = instance.getFilepath();
        assertEquals(expResult, result);
    }


    /**
     * Test of getFilehash method, of class Tag.
     */
    @Test
    public void testGetFilehash() {
        System.out.println("getFilehash");
        Tag instance = new Tag();
        instance.setFilehash("sdfjhf392fwfh389fw9fw");
        String expResult = "sdfjhf392fwfh389fw9fw";
        String result = instance.getFilehash();
        assertEquals(expResult, result);
    }

    /**
     * Test of getArtist method, of class Tag.
     */
    @Test
    public void testGetArtist() {
        System.out.println("getArtist");
        Tag instance = new Tag();
        instance.setArtist("An Artist");
        String expResult = "An Artist";
        String result = instance.getArtist();
        assertEquals(expResult, result);
    }

    /**
     * Test of getTitle method, of class Tag.
     */
    @Test
    public void testGetTitle() {
        System.out.println("getTitle");
        Tag instance = new Tag();
        instance.setTitle("A Title");
        String expResult = "A Title";
        String result = instance.getTitle();
        assertEquals(expResult, result);
    }


    /**
     * Test of getSecs method, of class Tag.
     */
    @Test
    public void testGetSecs() {
        System.out.println("getSecs");
        Tag instance = new Tag();
        instance.setSecs(100);
        int expResult = 100;
        int result = instance.getSecs();
        assertEquals(expResult, result);
    }


    /**
     * Test of m3uvalue method, of class Tag.
     */
    @Test
    public void testM3uvalue() {
        System.out.println("m3uvalue");
        Tag instance = new Tag();
        instance.setSecs(100);
        instance.setArtist("Various Artists");
        instance.setTitle("White Noise");
        instance.setFilepath(Paths.get("/path/to/some/tunes/noise.mp3"));
        instance.setFilehash("2383vyrw8vrtve8tywea432t8vr");
        String expResult = "#EXTINF:100,Various Artists - White Noise";
        String result = instance.m3uvalue();
        assertEquals(expResult, result);
    }

    /**
     * Test of toString method, of class Tag.
     */
    @Test
    public void testToString() {
        System.out.println("toString");
        Tag instance = new Tag();
        instance.setSecs(100);
        instance.setArtist("Various Artists");
        instance.setTitle("White Noise");
        instance.setFilepath(Paths.get("/path/to/some/tunes/noise.mp3"));
        instance.setFilehash("2383vyrw8vrtve8tywea432t8vr");
        
        String expResult = "Song: \n Path: /path/to/some/tunes/noise.mp3,\nHash: "
                + "2383vyrw8vrtve8tywea432t8vr,\nArtist: Various Artists"
                + ",\nTitle: White Noise,\nLength 100s";
        String result = instance.toString();
        assertEquals(expResult, result);
    }
}