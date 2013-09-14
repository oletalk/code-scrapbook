/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.util;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;
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
        
        // need to read this property logfile=/tmp/test-server.log
        InputStream stream = ClassLoader.getSystemResourceAsStream("config.properties");
        Properties props = new Properties();
        
        String logfilename = null;
        
        try {
            props.load(stream);
            logfilename = (String)props.get("logfile");
            System.out.println("Log file name was given as " + logfilename);
            fh = new FileHandler(logfilename, false);
        } catch (IOException ex) {
            ex.printStackTrace();
        }
        
        
        //String logfilename = "/Users/colin/test-server.log";
        
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
