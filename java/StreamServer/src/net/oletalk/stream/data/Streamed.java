/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.data;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintStream;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.logging.Level;
import java.util.logging.Logger;
import net.oletalk.stream.util.LogSetup;

/**
 *
 * @author colin
 */
public class Streamed {
    
    private static final Logger LOG = LogSetup.getlog();
    
    private Path streamedPath = null;
    
    public void setStreamedPath(Path path)
    {
        streamedPath = path;
    }
    
    public void writeStream(OutputStream out)
    {
        if (streamedPath == null)
            throw new IllegalStateException("streamedPath not set yet");
        try (InputStream in = Files.newInputStream(streamedPath))
        {
            streamThrough(in, out);        
        } catch (IOException ex) {
            LOG.log(Level.WARNING, "Exception caught streaming the song: {0}", ex.toString());
        }
    }
    
    public void writeDownsampledStream(PrintStream out)
    {
        if (streamedPath == null)
            throw new IllegalStateException("streamedPath not set yet");        
        
        // TODO: this downsamples only mp3s.
        try  {
            String lame = "/opt/local/bin/lame";
    
            Runtime rt = Runtime.getRuntime();
            final Process proc = rt.exec( 
                    new String[]{lame, "--mp3input", "-b", "32", 
                            streamedPath.toString(), "--flush",
                            "-"} );
            InputStream in = proc.getInputStream();
            streamThrough(in, out);
        } catch (IOException ex) {
            LOG.log(Level.WARNING, "Exception caught streaming the DOWNSAMPLED song: {0}", ex.toString());
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
