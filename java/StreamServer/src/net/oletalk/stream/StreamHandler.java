/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream;

import java.util.logging.Level;
import java.util.logging.Logger;
import net.oletalk.stream.actor.Command;
import net.oletalk.stream.data.SongList;
import net.oletalk.stream.util.LogSetup;
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
                    Command cmd = new Command(response, rootdir);
                    switch (cmdStr) {
                        case Command.PLAY:
                            cmd.play(list, path);
                            break;
                        case Command.LIST:
                            cmd.list(list, path);
                            break;
                        case Command.DROP:
                            cmd.drop(list, path);
                            break;
                        default:
                            cmd.doDefault();
                            break;
                    }
                }
                
            }
            
        } catch (Exception e) {
            LOG.log(Level.SEVERE, "Problem handling request", e);
        }
    }
    
}