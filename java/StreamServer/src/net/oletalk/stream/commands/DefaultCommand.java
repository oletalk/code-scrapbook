/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.commands;

import com.sun.net.httpserver.HttpExchange;
import java.io.OutputStream;
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
        
        long time = System.currentTimeMillis();

        if (exchange == null) 
        {
            try (PrintStream body = response.getPrintStream()) {
                Header.setHeaders(response, Header.HeaderType.TEXT);
                response.setDate("Date", time);
                response.setDate("Last-Modified", time);
                body.println("400 Bad Request");

            }
        }
        else {
            String str = "Bad Request";
            Header.setHeaders(exchange, Header.HeaderType.TEXT);
            exchange.sendResponseHeaders(400, str.length());
            try (OutputStream body = exchange.getResponseBody()) {
                body.write(str.getBytes());
            }
        }

    }
    
}
