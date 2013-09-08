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

/**
 *
 * @author colin
 */
public class DefaultCommand extends AbstractCommand {
    
    public DefaultCommand(HttpExchange exchange, String rootdir)
    {
        super(exchange, rootdir);
    }
    
    @Override
    public void exec(Map<String, Object> args) throws Exception
    {
        
        long time = System.currentTimeMillis();

        String str = "Bad Request";
        Header.setHeaders(exchange, Header.HeaderType.TEXT);
        exchange.sendResponseHeaders(400, str.length());
        try (OutputStream body = exchange.getResponseBody()) {
            body.write(str.getBytes());
        }

    }
    
}
