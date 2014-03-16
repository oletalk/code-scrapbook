/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.data;

import net.oletalk.stream.util.Util;

/**
 *
 * @author colin
 */
public class Tag {
    
//    private Path filepath;
//    private String filehash;
    private String artist;
    private String title;
    private int secs;
    private long song_id; // CM TODO: why not Song object?

    public long getSong_id() {
        return song_id;
    }

    public void setSong_id(long song_id) {
        this.song_id = song_id;
    }

    public String getArtist() 
    {
        return artist;
    }

    public void setArtist(String artist) 
    {
        this.artist = Util.truncate(artist, 100);
        // maximum varchar(100)
        
    }

    public String getTitle() 
    {
        return title;
    }

    public void setTitle(String title) 
    {
        this.title = Util.truncate(title, 200);
        //maximum varchar(200)
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
    
    public boolean equals(Tag otherTag)
    {
        return otherTag != null && this.toString().equals(otherTag.toString());
    }
    
    @Override
    public String toString()
    {
        StringBuilder sb = new StringBuilder();

        sb.append("Tag: \n Path: ").append(",\nArtist: ").append(artist)
                .append(",\nTitle: ").append(title).append(",\nLength ")
                .append(secs).append("s");
        return sb.toString();
    }
    
}
