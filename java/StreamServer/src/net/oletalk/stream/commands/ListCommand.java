/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.commands;

import com.sun.net.httpserver.HttpExchange;
import java.io.OutputStream;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Map;
import java.util.logging.Level;
import net.oletalk.stream.data.Header;
import net.oletalk.stream.data.SongList;

/**
 *
 * @author colin
 */
public class ListCommand extends AbstractCommand {
    
    public ListCommand(HttpExchange exchange, String rootdir)
    {
        super(exchange, rootdir);
    }
    
    @Override
    public void exec(Map<String, Object> args) throws Exception {
        
        String uri = (String)args.get("uri");
        SongList list = (SongList)args.get("list");
        // Unescape it
        String path = uri;
        
        long time = System.currentTimeMillis();

        String pathreq = rootdir + path;
        Path listdir = Paths.get(pathreq);
        LOG.log(Level.FINE, "Received LIST command");

        String html = getHeaderHtml() + list.asHTML(listdir);

        
        Header.setHeaders(exchange, Header.HeaderType.HTML);
        exchange.sendResponseHeaders(200, 0);

        try (OutputStream body = exchange.getResponseBody()) {    
            body.write(html.getBytes());
        }
            
    }
    
    public String getHeaderHtml(){
        return "<h2>List of songs</h2><p><a href='/r/drop'>Download playlist</a></p>";
    }
    
}
