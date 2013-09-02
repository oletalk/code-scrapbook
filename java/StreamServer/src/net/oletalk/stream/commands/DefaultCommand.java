/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.commands;

import com.sun.net.httpserver.HttpExchange;
import java.io.PrintStream;
import java.util.Map;
import net.oletalk.stream.data.Header;
import org.simpleframework.http.Response;

/**
 *
 * @author colin
 */
public class DefaultCommand extends AbstractCommand {

    public DefaultCommand(Response response, String rootdir)
    {
        super(response, rootdir);
    }
    
    public DefaultCommand(HttpExchange exchange, String rootdir)
    {
        super(exchange, rootdir);
    }
    
    @Override
    public void exec(Map<String, Object> args) throws Exception
    {
        
        try (PrintStream body = response.getPrintStream()) {
            long time = System.currentTimeMillis();

            Header.setHeaders(response, Header.HeaderType.TEXT);
            response.setDate("Date", time);
            response.setDate("Last-Modified", time);
            body.println("400 Bad Request");
        }

    }
    
}
