/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.data;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.logging.Level;
import java.util.logging.Logger;
import net.oletalk.stream.util.LogSetup;
import net.oletalk.stream.util.TagReader;

/**
 *
 * @author colin
 */
public class Song {
    
    private Path path;
    private Tag tag;

    public Tag getTag() {
        return tag;
    }

    public void setTag(Tag tag) {
        this.tag = tag;
    }
    private static final Logger LOG = LogSetup.getlog();
    
    public Song (Path path)
    {
        this.path = path;
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
        return str;
    }
    
    public void writeStream(PrintStream out)
    {
        Charset charset = Charset.forName("UTF-8");

        try (BufferedInputStream is = new BufferedInputStream(Files.newInputStream(path)))
        {
            int content;
            while ((content = is.read()) != -1)
            {
                out.print((char)content);
            }
            LOG.fine("Done streaming song.");
            
        } catch (IOException x) {
            LOG.log(Level.WARNING, "Exception caught streaming the song: {0}", x.toString());
            
        }
    }
    
    public String htmlValue(Path rootpath)
    {
        String st = this.pathFrom(rootpath);
            // paths with accents in them don't work
        String st_enc = URLEncoder.encode(st);

        return "<a href=\"/play/" + st_enc + "\">" + st + "<br/>\n";
    }
    
    public String m3uValue(String hostheader, Path rootpath)
    {
        StringBuilder sb = new StringBuilder();
        Path p = rootpath.relativize(path);
        String pathstr = hostheader + p.toString();
        if (tag != null)
        {
            pathstr = tag.m3uvalue() + "\n" + pathstr;
        }
        else
        {
            pathstr = "#EXTINF:-1," + path.getFileName().toString() + pathstr;
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

    public void populateTag() {
        setTag(TagReader.getBean().get(path));
    }
}
