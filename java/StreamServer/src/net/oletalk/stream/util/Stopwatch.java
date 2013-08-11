/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.util;

/**
 *
 * Quick 'stopwatch' class - giving it a 'true' argument starts it right away
 * and calling 'elapsedtime' stops it if it isn't stopped
 * @author colin
 */
public class Stopwatch {

    private long starttime = 0;
    private long stoptime = 0;
    
    public Stopwatch()
    {
        
    }
    
    public Stopwatch(boolean startNow)
    {
        if (startNow)
            start();
    }
    
    public final void start()
    {
        starttime = System.currentTimeMillis();
    }
    
    public final void stop() {
        stoptime = System.currentTimeMillis();
    }
    
    public long elapsedTime() {
        stop();
        return stoptime - starttime;
    }
}
