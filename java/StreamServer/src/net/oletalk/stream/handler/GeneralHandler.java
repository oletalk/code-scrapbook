/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.handler;

import com.sun.net.httpserver.Headers;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import java.io.IOException;
import java.io.OutputStream;
import java.util.Arrays;
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
    
    @Autowired
    protected SongList list;

    protected @Value("${rootdir}") String rootdir;

    // stuff to pass to continueHandle
    protected FilterAction.Action action = null;
    protected Set<FilterAction.Option> options = null;
    protected String path;
    protected Headers hr;
    
    protected String[] allowedCommands;
        
    public GeneralHandler(String[] allowedCommands)
    {
        this.allowedCommands = allowedCommands;
    }
    
    @Override
    public void handle(HttpExchange he) throws IOException {
                
        try {
                        
            String uri = he.getRequestURI().getPath();
            if (uri != null && uri.startsWith("/"))
            {
                // For the time being, the URI is split up this way:
                /* /s/play/My%20Song.mp3 =
                   /s = context (1)
                   /play = command (2)
                   /My%20Song.mp3 (3) 
                */
                String[] cmdargs = uri.split("/", 4);
                String context = cmdargs[1]; // TODO - should we do anything with this?
                String cmdStr = cmdargs[2];
                path = "";
                if (cmdargs.length > 3) {
                    StringBuilder sb = new StringBuilder();
                    for (int x = 3; x < cmdargs.length; x++)
                        sb.append(cmdargs[x]);
    
                    path = sb.toString();
                }
                                
                if (cmdStr != null)
                {
                    hr = he.getRequestHeaders();
                    
                    String remotehost = he.getRemoteAddress().getHostString();

                    FilterAction fa = clientlist.filterActionFor(remotehost);
                    action = clientlist.getDefaultAction();
                    options = null;
                    
                    if (fa != null)
                    {
                        action = fa.getAction();
                        options = fa.getOptions();
                    }
                    
                    stats.countStat("CLIENT_ACTION", action.toString());
                    stats.countStat("CLIENT", remotehost);
                    
                    final AbstractCommand cmd;
                    if (allowedCommands != null)
                    {
                        if (Arrays.asList(allowedCommands).contains(cmdStr))
                        {
                            cmd = factory.create(cmdStr, he, rootdir);
                            handleAccess(he, cmd);
                        } else {
                            throw new IllegalArgumentException("This type of handler doesn't support the '" + cmdStr + "' command");
                        }
                    }
                    
                }
                
            }
            
        } catch (Exception e) {
            LOG.log(Level.SEVERE, "Problem handling request", e);
        } finally {
            he.close();
        }
    }
    
    // overrideable as well
    public void handleAccess(HttpExchange he, AbstractCommand cmd) throws Exception
    {
        if (action == FilterAction.Action.ALLOW) {
            continueHandle(cmd); // <-- OVERRIDE THIS IN SUBCLASS
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
    
    // your handler-specific code here
    public abstract void continueHandle(AbstractCommand cmd) throws Exception;
    
}
