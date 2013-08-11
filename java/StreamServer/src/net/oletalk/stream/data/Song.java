/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.data;

import java.io.BufferedInputStream;
import java.io.IOException;
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
public class Song {
    
    private Path path;
    private static final Logger LOG = LogSetup.getlog();
    
    public Song (Path path)
    {
        this.path = path;
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
            
        } catch (IOException x) {
            LOG.log(Level.WARNING, "Exception caught streaming the song: {0}", x.toString());
            
        }
    }
    
    @Override
    public String toString()
    {
        return "Song: " + path.toString();
    }
}
