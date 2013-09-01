/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.commands;

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
public class DropCommand extends AbstractCommand {

    public DropCommand(Response response, String rootdir) {
        super(response, rootdir);
    }

    @Override
    public void exec(Map<String, Object> args) throws Exception {
        
        String uri = (String)args.get("uri");
        SongList list = (SongList)args.get("list");
        String hostheader = (String)args.get("hostheader");
        
        try (PrintStream body = response.getPrintStream()) {
            long time = System.currentTimeMillis();
            String pathreq = rootdir + uri;
            Path listdir = Paths.get(pathreq);
            LOG.log(Level.FINE, "Received DROP command");

            // TODO: This won't be ready/usable until all song tags are populated
            String html = list.M3UforList(listdir, hostheader);

            Header.setHeaders(response, Header.HeaderType.TEXT);
            response.setDate("Date", time);
            response.setDate("Last-Modified", time);
            body.println(html);
            
        }
    }
    
}
