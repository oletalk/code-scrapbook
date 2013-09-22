/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.data;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.file.Path;
import java.util.logging.Level;
import java.util.logging.Logger;
import net.oletalk.stream.util.LogSetup;
import net.oletalk.stream.actor.TagReader;
import net.oletalk.stream.interfaces.HTMLRepresentable;

/**
 *
 * @author colin
 */
public class Song extends Streamed implements HTMLRepresentable {
    
    private Tag tag;

    private static final String PLAYURL = "/s/play/";
    
    public Tag getTag() {
        return tag;
    }

    public Path getPath() {
        return streamedPath;
    }
    
    public void setTag(Tag tag) {
        this.tag = tag;
        
        if (tag == null)
        {
            LOG.log(Level.WARNING, "Tag for song {0} is NULL", this.toString());
        }
        
        if (tag != null && !this.streamedPath.equals(tag.getFilepath()))
        {
            LOG.log(Level.WARNING, "Tag filepath != song path, as we expected - fixing that");
            this.tag.setFilepath(this.streamedPath);
        }
        
    }
    private static final Logger LOG = LogSetup.getlog();
    
    public Song (Path path)
    {
        super(path);
    }
    
    private String pathFrom(Path path)
    {
        Path p = path.relativize(this.streamedPath);
        String str = null;
        try {
            str = new String(p.toString().getBytes("UTF8"));
        } catch (UnsupportedEncodingException ex) {
            LOG.log(Level.SEVERE, "Problems getting path from " + this.streamedPath.toString(), ex);
        }
        
        // paths with accents in them don't work
        String st_enc = URLEncoder.encode(str);

        return st_enc;
    }
        
    @Override
    public String asHTML(Path rootpath)
    {
        String st = this.pathFrom(rootpath);
        String st_dec = st;
        try {
            st_dec = URLDecoder.decode(st, "UTF-8");
        } catch (UnsupportedEncodingException uee) { }
        return "<a href=\"" + PLAYURL + st + "\">" + st_dec + "<br/>\n";
    }
    
    public String m3uValue(String hostheader, Path rootpath)
    {
        //Path p = rootpath.relativize(path);
        String st = this.pathFrom(rootpath);

        String pathstr = "http://" + hostheader + PLAYURL + st;
        if (tag != null)
        {
            pathstr = tag.m3uvalue() + "\n" + pathstr + "\n";
        }
        else
        {
            pathstr = "#EXTINF:-1," + streamedPath.getFileName().toString() + "\n" + pathstr + "\n";
        }
        return pathstr;
    }
        
    @Override
    public String toString()
    {
        StringBuilder sb = new StringBuilder();
        sb.append("Song: ").append(streamedPath.toString());
        if (tag != null)
        {
            sb.append("\nwith Tag:").append(tag.toString());        
        }
        return sb.toString();
    }

    void getTagFromReader(TagReader tagreader) {
        setTag(tagreader.get(streamedPath));
    }

}
