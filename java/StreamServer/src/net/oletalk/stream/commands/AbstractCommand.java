/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.commands;

import com.sun.net.httpserver.HttpExchange;
import java.util.Map;
import java.util.logging.Logger;
import net.oletalk.stream.util.LogSetup;

/**
 *
 * @author colin
 */
public abstract class AbstractCommand {
    
    protected static final Logger LOG = LogSetup.getlog();
    protected String rootdir;
    protected HttpExchange exchange;
    
    public AbstractCommand(HttpExchange exchange, String rootdir)
    {
        this.exchange = exchange;
        this.rootdir = rootdir;
    }
        
    public void exec() throws Exception
    {
        exec(null);
    }
    
    public abstract void exec(Map<String,Object> args) throws Exception;
        
}
