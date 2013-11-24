/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.commands;

import com.sun.net.httpserver.HttpExchange;
import java.io.OutputStream;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.logging.Level;
import static net.oletalk.stream.commands.AbstractCommand.LOG;
import net.oletalk.stream.data.Header;
import net.oletalk.stream.data.Song;
import net.oletalk.stream.data.SongList;

/**
 *
 * @author colin
 */
public class SearchCommand extends AbstractCommand {

    public SearchCommand(HttpExchange exchange, String rootdir) {
        super(exchange, rootdir);
    }
    
    @Override
    public void exec(Args args) throws Exception {
        String uri = args.getUri();
        SongList list = args.getList();
        
        String[] opts = uri.split("/"); // 0 = category, 1 = all/top10 ... etc TODO
        // 1st opt = actual criteria
        // 2nd opt = type (any, artist, title) 'any' is default
        String searchStr = null;
        String critType = "any";
        if (opts.length > 0) {
            searchStr = opts[0];
            if (opts.length > 1) {
                critType = opts[1];
            }
        }
        LOG.log(Level.INFO, "Search - criteria ''{0}'', Type of search: ''{1}''", 
                new Object[]{searchStr, critType});
        
        List<Song> results = null;
        String errorMsg = "No matching (currently tagged) songs were found!";
        try {
            results = list.findSongsByCriteria(Song.Attribute.get(critType), searchStr);
        } catch (Exception e) {
            errorMsg = e.getMessage();
        }
        
        StringBuilder sb = new StringBuilder("<h2>Search results</h2>");
        boolean noResultsFound = true;
        
        if (results != null) {
            Path rootPath = Paths.get(rootdir);
            for (Song s : results) {
                if (s.getPath().startsWith(rootPath)) {
                    noResultsFound = false;
                    sb.append(s.asHTML(rootPath));
                } else {
                    LOG.log(Level.FINE, "Song {0} found but not under current root path", s.toString());
                }
            }
            
        }
        
        if (noResultsFound) {
            sb.append("<b>").append(errorMsg).append("</b>");
        }
        LOG.log(Level.FINE, "Received SEARCH command");

        String html = sb.toString();

        Header.setHeaders(exchange, Header.HeaderType.HTML);
        exchange.sendResponseHeaders(200, 0);

        try (OutputStream body = exchange.getResponseBody()) {    
            body.write(html.getBytes());
        }

        
    }
    
}
