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
    
    private static final HashMap<String,Class> cmdTypes;
    
    static {
        // all your command types here:
        cmdTypes = new HashMap<>();
        cmdTypes.put(Command.DROP, DropCommand.class);
        cmdTypes.put(Command.LIST, ListCommand.class);
        cmdTypes.put(Command.PLAY, PlayCommand.class);
        
    }
    
    private static Class cmdFromType (String cmdType)
    {
        Class cls;
        cls = cmdTypes.get(cmdType);
        return cls != null ? cls : DefaultCommand.class;
    }
    
    
    public static AbstractCommand create(String cmdType, HttpExchange exchange, String rootdir) 
            throws Exception
    {
        Class cmdclass = cmdFromType(cmdType);
        Constructor cmdcon = cmdclass.getDeclaredConstructor(HttpExchange.class, String.class);
        //System.err.println("cmdclass = " + cmdclass);
        return (AbstractCommand)cmdcon.newInstance(exchange, rootdir);
    }
}
