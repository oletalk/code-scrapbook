/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.actor;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import net.oletalk.stream.data.Streamed;
import net.oletalk.stream.data.Streamed.AudioType;
import org.springframework.beans.factory.annotation.Value;

/**
 *
 * @author colin
 */
public class Downsampler {
        
    private final static String PLACEHOLDER = "[song]";
    
    @Value("${downsampler.mp3.command}")
    private String mp3DownsampleCommand;
    @Value("${downsampler.ogg.command}")
    private String oggDownsampleCommand;

    @Value("${downsampler.mp3.options}")
    private String mp3DownsampleOptions;
    @Value("${downsampler.ogg.options}")
    private String oggDownsampleOptions;
    
    public InputStream downsampled(Streamed stream) throws IOException
    {
        String[] mp3DownsampleArgs = mp3DownsampleOptions.split(" ");
        String[] oggDownsampleArgs = oggDownsampleOptions.split(" ");
        InputStream in = null;
        
        final Process proc;
        
        List<String> cmd = new ArrayList<>();
        
        AudioType type = stream.getAudioType();
        if (type == AudioType.MP3)
        {
            cmd.add(mp3DownsampleCommand);
            cmd.addAll(listSubstitute(mp3DownsampleArgs, stream.getStreamedPath().toString()));
        }
        else if (type == AudioType.OGG)
        {
            cmd.add(oggDownsampleCommand);
            cmd.addAll(listSubstitute(oggDownsampleArgs, stream.getStreamedPath().toString()));
        }
        
        if (cmd.isEmpty())
        {
            throw new IllegalArgumentException("Can't downsample: audioType for file not recognised or set");
        } else {
            ProcessBuilder builder = new ProcessBuilder(cmd);
            builder.redirectErrorStream(true);
            proc = builder.start();
            
            in = proc.getInputStream();

        }
        return in;
    }
    
    private List<String> listSubstitute(String[] args, String substituted)
    {
        List<String> ret = new ArrayList<>();
        for (String s : args)
        {
            ret.add(PLACEHOLDER.equals(s) ? substituted : s);
        }
        
        return ret;
    }
    
}
