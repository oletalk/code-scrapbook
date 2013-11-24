/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.handler;

import net.oletalk.stream.actor.Command;
import net.oletalk.stream.commands.AbstractCommand;
import net.oletalk.stream.commands.Args;

/**
 *
 * @author colin
 */
public class RenderHandler extends GeneralHandler {

    public RenderHandler()
    {
        super(new Command.Type[]{ 
            Command.Type.DROP, 
            Command.Type.LIST, 
            Command.Type.SEARCH,
            Command.Type.STATS });
    }
    
    @Override
    public void continueHandle(AbstractCommand cmd) throws Exception {
        Args args = new Args();
        args.setList(list);
        args.setUri(path);
        args.setHostheader(hr.getFirst("Host"));
        args.setCollector(stats);
        cmd.exec(args);
    }
    
}
