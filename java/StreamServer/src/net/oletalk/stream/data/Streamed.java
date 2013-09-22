/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.data;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.logging.Level;
import java.util.logging.Logger;
import net.oletalk.stream.actor.Downsampler;
import net.oletalk.stream.util.LogSetup;

/**
 *
 * @author colin
 */
public class Streamed {
    
    private static final Logger LOG = LogSetup.getlog();
    
    protected Path streamedPath = null;
    
    public Streamed(Path path)
    {
        streamedPath = path;
        
        String filename = this.streamedPath.getFileName().toString().toLowerCase();
        if (filename.endsWith(".ogg")) {
            this.audioType = AudioType.OGG;
        } else if (filename.endsWith(".mp3")) {
            this.audioType = AudioType.MP3;
        } else {
            this.audioType = AudioType.OTHER;
        }

    }
    
    public enum AudioType {
        MP3, OGG, OTHER
    }
    
    protected AudioType audioType;
    
    public AudioType getAudioType()
    {
        return audioType;
    }
    
    // TODO - why do we need this IN ADDITION TO path? No access to subclass path?
    public void setStreamedPath(Path path)
    {
        streamedPath = path;
    }
    
    public Path getStreamedPath()
    {
        return streamedPath;
    }
    
    public void writeStream(OutputStream out)
    {
        writeStream(out, null);
    }
    
    public void writeStream(OutputStream out, Downsampler downsampler)
    {
        if (streamedPath == null)
            throw new IllegalStateException("streamedPath not set yet");        
        
        InputStream in = null;
        try  {
            if (downsampler == null) { // regular stream
                in = Files.newInputStream(streamedPath);
                streamThrough(in, out);        
            }
            else {
                in = downsampler.downsampled(this);
                streamThrough(in, new BufferedOutputStream(out));        
            }
        } catch (Exception ex) {
            LOG.log(Level.WARNING, "Exception caught streaming the song: {0}", ex.toString());
        } finally {
            try {
                if (in != null) in.close();
            } catch (IOException ex) {
                LOG.log(Level.WARNING, "Problems cleaning up input stream after exception", ex);
            }
        }
    }
    
    
    
    private static void streamThrough(InputStream in, OutputStream out)
    {
        Charset charset = Charset.forName("UTF-8");

        try (BufferedInputStream is = new BufferedInputStream(in))
        {
            int content;
            while ((content = is.read()) != -1)
            {
                out.write((char)content);
            }
            LOG.fine("Done streaming.");
            
        } catch (IOException x) {
            LOG.log(Level.WARNING, "Exception caught streaming: {0}", x.toString());
            
        }
    }

}
