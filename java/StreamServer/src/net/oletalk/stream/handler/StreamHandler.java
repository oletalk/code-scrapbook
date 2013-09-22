/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.handler;

import java.util.HashMap;
import java.util.Map;
import net.oletalk.stream.actor.Command;
import net.oletalk.stream.actor.Downsampler;
import net.oletalk.stream.commands.AbstractCommand;
import net.oletalk.stream.data.FilterAction;
import org.springframework.beans.factory.annotation.Autowired;

/**
 *
 * HttpHandler for streaming requests only
 * 
 * @author colin
 */
public class StreamHandler extends GeneralHandler {
    
    @Autowired
    private Downsampler downsampler;
    
    public StreamHandler()
    {
        super(new String[]{ Command.PLAY });
    }
    
    @Override
    public void continueHandle(AbstractCommand cmd) throws Exception
    {
        boolean downsample = options != null && options.contains(FilterAction.Option.DOWNSAMPLE);
                    
        Map<String,Object> args = new HashMap<>();
        args.put("list", list);
        args.put("uri", path);
        args.put("hostheader", hr.getFirst("Host"));
        args.put("statscollector", stats);
        if (downsample)
        {
            args.put("downsampler", downsampler);                            
        }
        cmd.exec(args);  

    }
}
