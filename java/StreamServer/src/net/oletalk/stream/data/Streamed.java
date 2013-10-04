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
    
    private static final int DEFAULT_BUFFER_SIZE = 8192;
    
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
        writeStream(out, null, DEFAULT_BUFFER_SIZE);
    }
    
    public void writeStream(OutputStream out, Downsampler downsampler, int buffersize)
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
                // CM apparently we shouldn't buffer 'out' - too much buffering is a bad thing!
                streamThrough(in, out, buffersize);        
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
    
    private void streamThrough(InputStream in, OutputStream out)
    {
        streamThrough(in, out, DEFAULT_BUFFER_SIZE);
    }
    
    private void streamThrough(InputStream in, OutputStream out, int buffersize)
    {
        Charset charset = Charset.forName("UTF-8");
        LOG.log(Level.FINE, "Using buffer of size {0}", buffersize);
        try (BufferedInputStream is = new BufferedInputStream(in, buffersize))
        {
            int content;
            while ((content = is.read()) != -1)
            {
                out.write((char) content);
            }
            LOG.fine("Done streaming.");
            
        } catch (IOException x) {
            LOG.log(Level.WARNING, "Exception caught streaming: {0}", x.toString());
            
        }
    }

}
