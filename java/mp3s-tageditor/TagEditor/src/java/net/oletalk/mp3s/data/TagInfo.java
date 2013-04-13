/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.mp3s.data;

/**
 *
 * @author colin
 */
public class TagInfo {

    private String songFilepath;
    private String filehash;
    private String artist;
    private String title;

    public void setFilehash(String filehash) {
        this.filehash = filehash;
    }

    public void setSecs(int secs) {
        this.secs = secs;
    }

    public void setSongFilepath(String songFilepath) {
        this.songFilepath = songFilepath;
    }
    private int secs;
    
    public String getArtist() {
        return artist;
    }

    public void setArtist(String artist) {
        this.artist = artist;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getFilehash() {
        return filehash;
    }

    public int getSecs() {
        return secs;
    }

    public String getSongFilepath() {
        return songFilepath;
    }
    
    @Override
    public String toString() {
        return this.getClass().getSimpleName() + ": path: " + this.getSongFilepath() + ": hash: " + this.getFilehash();
    }
}
