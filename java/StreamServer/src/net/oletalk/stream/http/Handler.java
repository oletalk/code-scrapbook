/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.http;

import com.sun.net.httpserver.Headers;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import java.io.IOException;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;
import net.oletalk.stream.actor.ClientList;
import net.oletalk.stream.actor.Downsampler;
import net.oletalk.stream.actor.StatsCollector;
import net.oletalk.stream.commands.AbstractCommand;
import net.oletalk.stream.commands.CommandFactory;
import net.oletalk.stream.data.FilterAction;
import net.oletalk.stream.data.FilterAction.Action;
import net.oletalk.stream.data.FilterAction.Option;
import net.oletalk.stream.data.Header;
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
    private CommandFactory factory;
    
    @Autowired
    private ClientList clientlist;

    @Autowired
    private StatsCollector stats;
    
    @Autowired
    private Downsampler downsampler;
    
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
                    
                    String remotehost = he.getRemoteAddress().getHostString();

                    FilterAction fa = clientlist.filterActionFor(remotehost);
                    Action action = clientlist.getDefaultAction();
                    Set<Option> options = null;
                    
                    if (fa != null)
                    {
                        action = fa.getAction();
                        options = fa.getOptions();
                    }
                    
                    stats.countStat("CLIENT_ACTION", action.toString());
                    stats.countStat("CLIENT", remotehost);
                    
                    boolean downsample = options != null && options.contains(Option.DOWNSAMPLE);
                    
                    if (action == Action.ALLOW) {
                        final AbstractCommand cmd = factory.create(cmdStr, he, rootdir);
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
                    else if (action == Action.DENY) {
                        // send Access Denied
                        OutputStream ps = he.getResponseBody();
                        String html = "Access Denied";
                        Header.setHeaders(he, Header.HeaderType.TEXT);
                        he.sendResponseHeaders(401, html.length());
                        ps.write(html.getBytes());
                        ps.close();
                    }
                    else {
                        // just close the connection
                    }
                    
                }
                
            }
            
        } catch (Exception e) {
            LOG.log(Level.SEVERE, "Problem handling request", e);
        } finally {
            he.close();
        }
    }
}