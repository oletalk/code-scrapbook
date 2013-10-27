/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.data;

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
        
        String expResult = "Tag: \n Path: ,\n"
                + "Artist: Various Artists"
                + ",\nTitle: White Noise,\nLength 100s";
        String result = instance.toString();
        assertEquals(expResult, result);
    }
}