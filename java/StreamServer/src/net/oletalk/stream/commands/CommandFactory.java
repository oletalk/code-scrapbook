/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.commands;

import com.sun.net.httpserver.HttpExchange;
import java.lang.reflect.Constructor;
import java.util.HashMap;
import net.oletalk.stream.actor.Command;

/**
 *
 * @author colin
 */
public class CommandFactory {
    
    private final HashMap<Command.Type,Class> cmdTypes;
    
    public CommandFactory() 
    {
        // all your command types here:
        cmdTypes = new HashMap<>();
        cmdTypes.put(Command.Type.DROP, DropCommand.class);
        cmdTypes.put(Command.Type.LIST, ListCommand.class);
        cmdTypes.put(Command.Type.SEARCH, SearchCommand.class);
        cmdTypes.put(Command.Type.PLAY, PlayCommand.class);
        cmdTypes.put(Command.Type.STATS, StatsCommand.class);
        
    }
    
    private Class cmdFromType (Command.Type cmdType)
    {
        Class cls;
        cls = cmdTypes.get(cmdType);
        return cls != null ? cls : DefaultCommand.class;
    }
    
    
    public AbstractCommand create(Command.Type cmdType, HttpExchange exchange, String rootdir) 
            throws Exception
    {
        Class cmdclass = cmdFromType(cmdType);
        Constructor cmdcon = cmdclass.getDeclaredConstructor(HttpExchange.class, String.class);
        //System.err.println("cmdclass = " + cmdclass);
        return (AbstractCommand)cmdcon.newInstance(exchange, rootdir);
    }
}
