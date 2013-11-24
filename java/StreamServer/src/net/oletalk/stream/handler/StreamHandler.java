/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.handler;

import net.oletalk.stream.actor.Command;
import net.oletalk.stream.actor.Downsampler;
import net.oletalk.stream.commands.AbstractCommand;
import net.oletalk.stream.commands.Args;
import net.oletalk.stream.data.FilterAction;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;

/**
 *
 * HttpHandler for streaming requests only
 * 
 * @author colin
 */
public class StreamHandler extends GeneralHandler {
    
    @Autowired
    private Downsampler downsampler;
    
    private @Value("${buffersize}") int buffersize;
    
    public StreamHandler()
    {
        super(new Command.Type[]{ Command.Type.PLAY });
    }
    
    @Override
    public void continueHandle(AbstractCommand cmd) throws Exception
    {
        boolean downsample = options != null && options.contains(FilterAction.Option.DOWNSAMPLE);
                    
        Args args = new Args();
        args.setList(list);
        args.setUri(path);
        args.setBuffersize(buffersize);
        args.setHostheader(hr.getFirst("Host"));
        args.setCollector(stats);
        if (downsample)
        {
            args.setDownsampler(downsampler);                            
        }
        cmd.exec(args);  

    }
}
