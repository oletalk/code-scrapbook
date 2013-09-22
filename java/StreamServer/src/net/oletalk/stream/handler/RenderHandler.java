/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.handler;

import java.util.HashMap;
import java.util.Map;
import net.oletalk.stream.actor.Command;
import net.oletalk.stream.commands.AbstractCommand;

/**
 *
 * @author colin
 */
public class RenderHandler extends GeneralHandler {

    public RenderHandler()
    {
        super(new String[]{ Command.DROP, Command.LIST, Command.STATS });
    }
    
    @Override
    public void continueHandle(AbstractCommand cmd) throws Exception {
        Map<String,Object> args = new HashMap<>();
        args.put("list", list);
        args.put("uri", path);
        args.put("hostheader", hr.getFirst("Host"));
        args.put("statscollector", stats);
        cmd.exec(args);
    }
    
}
