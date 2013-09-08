/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.http;

import com.sun.net.httpserver.Headers;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import net.oletalk.stream.commands.AbstractCommand;
import net.oletalk.stream.commands.CommandFactory;
import net.oletalk.stream.data.SongList;
import net.oletalk.stream.util.LogSetup;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;

/**
 *
 * @author colin
 */
public class Handler implements HttpHandler {

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
    public void handle(HttpExchange he) throws IOException {
                
        try {
                        
            String uri = he.getRequestURI().getPath();
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
                    Headers hr = he.getRequestHeaders();
                    System.out.println("Remote host: " + he.getRemoteAddress().getHostString());
                    // TODO: client filtering/downsampling depending on IP range/config file
                    
                    AbstractCommand cmd = CommandFactory.create(cmdStr, he, rootdir);
                    Map<String,Object> args = new HashMap<>();
                    args.put("list", list);
                    args.put("uri", path);
                    args.put("hostheader", hr.getFirst("Host"));
                    cmd.exec(args);
                    
                }
                
            }
            
        } catch (Exception e) {
            LOG.log(Level.SEVERE, "Problem handling request", e);
        }
    }
}