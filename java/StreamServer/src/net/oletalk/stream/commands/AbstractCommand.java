/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.commands;

import java.util.Map;
import java.util.logging.Logger;
import net.oletalk.stream.util.LogSetup;
import org.simpleframework.http.Response;

/**
 *
 * @author colin
 */
public abstract class AbstractCommand {
    
    protected static final Logger LOG = LogSetup.getlog();
    protected Response response;
    protected String rootdir;
    
    public AbstractCommand(Response response, String rootdir)
    {
        this.response = response;
        this.rootdir = rootdir;
    }
    
    public void exec() throws Exception
    {
        exec(null);
    }
    
    public abstract void exec(Map<String,Object> args) throws Exception;
        
}
