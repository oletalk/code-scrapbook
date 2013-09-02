/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.commands;

import com.sun.net.httpserver.Headers;
import com.sun.net.httpserver.HttpExchange;
import java.io.OutputStream;
import java.io.PrintStream;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Map;
import java.util.logging.Level;
import net.oletalk.stream.data.Header;
import net.oletalk.stream.data.SongList;
import org.simpleframework.http.Response;

/**
 *
 * @author colin
 */
public class ListCommand extends AbstractCommand {

    public ListCommand(Response response, String rootdir)
    {
        super(response, rootdir);
    }
    
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

        // TODO: Use paths to figure out which files are below the given URI
        String pathreq = rootdir + path;
        Path listdir = Paths.get(pathreq);
        LOG.log(Level.FINE, "Received LIST command");

        String html = getHeaderHtml() + list.HTMLforList(listdir);

        // ------ OLD VERSION ----------
        if (exchange == null) {
            try (PrintStream body = response.getPrintStream()) {

                Header.setHeaders(response, Header.HeaderType.HTML);
                response.setDate("Date", time);
                response.setDate("Last-Modified", time);
                body.println(html);
            }
            
        }
        else {
        
            // --------- NEW VERSION ----------
            Header.setHeaders(exchange, Header.HeaderType.HTML);
            exchange.sendResponseHeaders(200, html.length());

            try (OutputStream body = exchange.getResponseBody()) {    
                body.write(html.getBytes());
            }
            
        }
    }
    
    public String getHeaderHtml(){
        return "<h2>List of songs</h2><p><a href='/drop'>Download playlist</a></p>";
    }
    
}
