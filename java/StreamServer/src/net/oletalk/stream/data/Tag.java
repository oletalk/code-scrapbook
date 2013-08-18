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
public class Tag {
    
    private Path filepath;
    private String filehash;
    private String artist;
    private String title;
    private int secs;

    public Path getFilepath() 
    {
        return filepath;
    }

    public void setFilepath(Path filepath) 
    {
        this.filepath = filepath;
    }

    public String getFilehash() 
    {
        return filehash;
    }

    public void setFilehash(String filehash) 
    {
        this.filehash = filehash;
    }

    public String getArtist() 
    {
        return artist;
    }

    public void setArtist(String artist) 
    {
        this.artist = artist;
    }

    public String getTitle() 
    {
        return title;
    }

    public void setTitle(String title) 
    {
        this.title = title;
    }

    public int getSecs() 
    {
        return secs;
    }

    public void setSecs(int secs) 
    {
        this.secs = secs;
    }
    
    public String m3uvalue()
    {
        StringBuilder sb = new StringBuilder();
        sb.append("#EXTINF:").append(this.secs).append(",").append(this.artist).append(" - ").append(this.title);
        return sb.toString();
    }
    
    @Override
    public String toString()
    {
        StringBuilder sb = new StringBuilder();

        sb.append("Song: \n Path: ").append(filepath.toString()).append(",\nHash: ")
                .append(filehash).append(",\nArtist: ").append(artist)
                .append(",\nTitle: ").append(title).append(",\nLength ")
                .append(secs).append("s");
        return sb.toString();
    }
    
}
