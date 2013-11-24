/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.commands;

import com.sun.net.httpserver.HttpExchange;
import java.io.OutputStream;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.logging.Level;
import net.oletalk.stream.data.Header;
import net.oletalk.stream.data.SongList;

/**
 *
 * @author colin
 */
public class DropCommand extends AbstractCommand {

    public DropCommand(HttpExchange exchange, String rootdir)
    {
        super(exchange, rootdir);
    }
    
    @Override
    public void exec(Args args) throws Exception {
        
        String uri = args.getUri();
        SongList list = args.getList();
        String hostheader = args.getHostheader();
        
        long time = System.currentTimeMillis();
        String pathreq = rootdir + uri;
        Path listdir = Paths.get(pathreq);
        LOG.log(Level.FINE, "Received DROP command");

        // TODO: This won't be ready/usable until all song tags are populated
        String html = list.M3UforList(listdir, hostheader);
        
            
        Header.setHeaders(exchange, Header.HeaderType.TEXT);
        exchange.sendResponseHeaders(200, 0);

        try (OutputStream body = exchange.getResponseBody()) {
            body.write(html.getBytes());
        }
    }
    
}
