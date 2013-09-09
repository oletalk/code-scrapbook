/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.util;

import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PipedInputStream;
import java.io.PipedOutputStream;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author colin
 */
public class TesterOutputStream {
    
    private BufferedOutputStream out;
    private BufferedReader reader = null;
        
    public OutputStream getOutputStream() throws IOException
    {
        PipedInputStream pipeInput = new PipedInputStream();
        reader = new BufferedReader(new InputStreamReader(pipeInput));
        out = new BufferedOutputStream(new PipedOutputStream(pipeInput));
        return out;
    }
    
    public String result()
    {
        if (reader == null) {
            throw new IllegalStateException("Should call getOutputStream() first");
        }
        StringBuilder sb = new StringBuilder();

        try {
            String x;
            while ((x = reader.readLine()) != null)
            {
                sb.append(x);
            }
        } catch (IOException ex) {
            System.err.println("Can't get the result: " + ex.getMessage());
        }
        return sb.toString();
    }

}
