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
import net.oletalk.stream.actor.StatsCollector;
import net.oletalk.stream.commands.AbstractCommand;
import net.oletalk.stream.commands.CommandFactory;
import net.oletalk.stream.data.FilterAction;
import net.oletalk.stream.data.Header;
import net.oletalk.stream.data.SongList;
import net.oletalk.stream.util.LogSetup;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;

/**
 *
 * Generic handler with no (or very little) Command-specific behaviour in.
 * 
 * @author colin
 */

public abstract class GeneralHandler implements HttpHandler {

    protected static final Logger LOG = LogSetup.getlog();
    
    @Autowired
    protected ClientList clientlist;

    @Autowired
    protected StatsCollector stats;

    @Autowired
    protected CommandFactory factory;
    
    protected SongList list;

    protected @Value("${rootdir}") String rootdir;

    protected FilterAction.Action action = null;
    protected Set<FilterAction.Option> options = null;
    
    
    // should use this within your 'handle' method below when overriding
    protected void preprocess(HttpExchange he)
    {
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

                FilterAction filteraction = clientlist.filterActionFor(remotehost);
                action = clientlist.getDefaultAction();
                options = null;

                if (filteraction != null)
                {
                    action = filteraction.getAction();
                    options = filteraction.getOptions();
                }

                stats.countStat("CLIENT_ACTION", action.toString());
                stats.countStat("CLIENT", remotehost);

                //boolean downsample = options != null && 
                // options.contains(FilterAction.Option.DOWNSAMPLE);
            }
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
                    FilterAction.Action action = clientlist.getDefaultAction();
                    Set<FilterAction.Option> options = null;
                    
                    if (fa != null)
                    {
                        action = fa.getAction();
                        options = fa.getOptions();
                    }
                    
                    stats.countStat("CLIENT_ACTION", action.toString());
                    stats.countStat("CLIENT", remotehost);
                    // -----------------------------------------------
                    boolean downsample = options != null && options.contains(FilterAction.Option.DOWNSAMPLE);
                    
                    if (action == FilterAction.Action.ALLOW) {
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
                    else if (action == FilterAction.Action.DENY) {
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
    
    // your handler-specific code here
    public abstract void continueHandle();
    
}
