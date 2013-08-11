/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.util;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 *
 * @author colin
 */
public class Config {
    
    private static Properties prop = new Properties();
    
    public static void init() throws IOException
    {
        init(null);
    }
    
    public static void init(String filename) throws IOException
    {
        String pathname = filename == null ? "config.properties" : filename;
        ClassLoader loader = Thread.currentThread().getContextClassLoader();
        InputStream stream = loader.getResourceAsStream("config.properties");
        prop.load(stream);
    }
    
    public static String get(String name)
    {
        Object rval = prop.get(name);
        return (rval == null ? null : rval.toString());
    }
    
}
