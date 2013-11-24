/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.commands;

import com.sun.net.httpserver.HttpExchange;
import java.io.OutputStream;
import java.util.Map;
import java.util.logging.Level;
import net.oletalk.stream.actor.StatsCollector;
import net.oletalk.stream.data.Header;

/**
 *
 * @author colin
 */
public class StatsCommand extends AbstractCommand {

    public StatsCommand(HttpExchange exchange, String rootdir) {
        super(exchange, rootdir);
    }

    @Override
    public void exec(Args args) throws Exception {
        StatsCollector sc = args.getCollector();
        String uri = args.getUri();
        // Unescape it
        String path = uri;
        
        LOG.log(Level.FINE, "Received STATS command");
        // TODO: how to specify different types of stats?
        
        String category = null;
        String[] opts = path.split("/"); // 0 = category, 1 = all/top10 ... etc TODO
        if (!"".equals(opts[0]))
            category = opts[0].toUpperCase();
        
        String html = sc.fetchStats(category, null);

        Header.setHeaders(exchange, Header.HeaderType.HTML);
        exchange.sendResponseHeaders(200, 0);

        try (OutputStream body = exchange.getResponseBody()) {    
            body.write(html.getBytes());
        }

    }
    
}
