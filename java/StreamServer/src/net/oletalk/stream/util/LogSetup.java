/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.util;

import java.io.IOException;
import java.util.logging.FileHandler;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.logging.SimpleFormatter;

/**
 *
 * @author colin
 */
public class LogSetup {
    
    private static FileHandler fh = null;
            
    public static Logger getlog() {
        
        String logfilename = "/Users/colin/test-server.log";
        
        try {
            fh = new FileHandler(logfilename, false);
        } catch (SecurityException | IOException e) {
            e.printStackTrace();
        }
        Logger l = Logger.getLogger("StreamServer");
        fh.setFormatter(new SimpleFormatter());
        if (l.getHandlers().length == 0)
        {
            System.out.println("Adding log handler -> " + logfilename);
            l.addHandler(fh);
        }
        l.setLevel(Level.FINE);
        
        return l;
    }
}
