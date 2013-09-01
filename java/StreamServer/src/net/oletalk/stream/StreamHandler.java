/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream;

import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import net.oletalk.stream.actor.Command;
import net.oletalk.stream.commands.AbstractCommand;
import net.oletalk.stream.commands.CommandFactory;
import net.oletalk.stream.data.SongList;
import net.oletalk.stream.util.LogSetup;
import net.oletalk.stream.util.Util;
import org.simpleframework.http.Request;
import org.simpleframework.http.Response;
import org.simpleframework.http.core.Container;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;

/**
 *
 * @author colin
 */
public class StreamHandler implements Container {
    
    private static final Logger LOG = LogSetup.getlog();
    
    private SongList list;
    private @Value("${rootdir}") String rootdir;
    
    @Autowired
    public void setSongList(SongList list) 
    {
        this.list = list;
        LOG.log(Level.CONFIG, "Song list: {0}", list.toString());
        
        // no songs? DIE
        if (this.list.hasNoSongs())
        {
            System.err.println("NO SONGS FOUND!");
            System.exit(1);
        }
    }
        
    @Override
    public void handle (Request request, Response response)
    {
        try {
                        
            String uri = request.getPath().toString();
            if (uri != null && uri.startsWith("/"))
            {
                String[] cmdargs = uri.split("/", 3);
                String cmdStr = cmdargs[1];
                String path = "";
                if (cmdargs.length > 2) {
                    path = cmdargs[2];                    
                }
                                
                if (cmdStr != null)
                {
                    
                    AbstractCommand cmd = CommandFactory.create(cmdStr, response, rootdir);
                    Map<String,Object> args = new HashMap<>();
                    args.put("list", list);
                    args.put("uri", path);
                    args.put("hostheader", Util.getHostHeader(request.getHeader()));
                    cmd.exec(args);
                    
                }
                
            }
            
        } catch (Exception e) {
            LOG.log(Level.SEVERE, "Problem handling request", e);
        }
    }
    
}
