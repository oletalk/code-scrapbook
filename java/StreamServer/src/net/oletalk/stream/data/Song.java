/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.data;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.file.Path;
import java.util.logging.Level;
import java.util.logging.Logger;
import net.oletalk.stream.util.LogSetup;
import net.oletalk.stream.actor.TagReader;

/**
 *
 * @author colin
 */
public class Song extends Streamed {
    
    private Path path;
    private Tag tag;

    public Tag getTag() {
        return tag;
    }

    public Path getPath() {
        return path;
    }
    
    public void setTag(Tag tag) {
        this.tag = tag;
    }
    private static final Logger LOG = LogSetup.getlog();
    
    public Song (Path path)
    {
        this.path = path;
        this.setStreamedPath(path);
        
        String filename = this.path.getFileName().toString();
        if (filename.endsWith(".ogg")) {
            this.audioType = AudioType.OGG;
        } else if (filename.endsWith(".mp3")) {
            this.audioType = AudioType.MP3;
        } else {
            this.audioType = AudioType.OTHER;
        }
    }
    
    public String pathFrom(Path path)
    {
        Path p = path.relativize(this.path);
        String str = null;
        try {
            str = new String(p.toString().getBytes("UTF8"));
        } catch (UnsupportedEncodingException ex) {
            LOG.log(Level.SEVERE, "Problems getting path from " + this.path.toString(), ex);
        }
        
        // paths with accents in them don't work
        String st_enc = URLEncoder.encode(str);

        return st_enc;
    }
        
    public String htmlValue(Path rootpath)
    {
        String st = this.pathFrom(rootpath);

        return "<a href=\"/play/" + st + "\">" + st + "<br/>\n";
    }
    
    public String m3uValue(String hostheader, Path rootpath)
    {
        //Path p = rootpath.relativize(path);
        String st = this.pathFrom(rootpath);

        String pathstr = "http://" + hostheader + "/play/" + st;
        if (tag != null)
        {
            pathstr = tag.m3uvalue() + "\n" + pathstr + "\n";
        }
        else
        {
            pathstr = "#EXTINF:-1," + path.getFileName().toString() + "\n" + pathstr + "\n";
        }
        return pathstr;
    }
        
    @Override
    public String toString()
    {
        StringBuilder sb = new StringBuilder();
        sb.append("Song: ").append(path.toString());
        if (tag != null)
        {
            sb.append("\nwith Tag:").append(tag.toString());        
        }
        return sb.toString();
    }

    void getTagFromReader(TagReader tagreader) {
        setTag(tagreader.get(path));
    }

}
