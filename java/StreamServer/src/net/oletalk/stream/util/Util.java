/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.util;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.DigestInputStream;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author colin
 */
public class Util {
    
    private static final Logger LOG = LogSetup.getlog();
    final protected static char[] hexArray = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};

    public static String uriencoded(Path path)
    {
        return null;
    }
    
    public static String computeMD5(Path path)
    {
        String ret = null;
        
        MessageDigest m = null;
        try {
            m = MessageDigest.getInstance("MD5");
        } catch (NoSuchAlgorithmException ns) {
            LOG.log(Level.SEVERE, "Problems using MD5 algorithm", ns);
        }

        if (m != null) 
        {
            try (
                    InputStream is = Files.newInputStream(path);
                    DigestInputStream dis = new DigestInputStream(is, m)
                    ) {
                byte[] buffer = new byte[1024];
                int numRead;
                do {
                    numRead = dis.read(buffer);
                    if (numRead > 0) {
                        m.update(buffer, 0, numRead);
                    }
                } while (numRead != -1);
                ret = bytesToHex(m.digest());
            } catch ( IOException ex) {
                LOG.log(Level.SEVERE, "Problems generating MD5 checksum for file", ex);
            }
        }
        return ret;
    }
    
    private static String bytesToHex(byte[] bytes) {
        char[] hexChars = new char[bytes.length * 2];
        int v;
        for ( int j = 0; j < bytes.length; j++ ) {
            v = bytes[j] & 0xFF;
            hexChars[j * 2] = hexArray[v >>> 4];
            hexChars[j * 2 + 1] = hexArray[v & 0x0F];
        }
        return new String(hexChars);
    }
    
    public static void sleep(int secs) {
        try {
            Thread.sleep(secs * 1000);
        } catch (InterruptedException ie) {}
    }
    
    // (grabbed off http://stackoverflow.com/questions/9655181/convert-from-byte-array-to-hex-string-in-java)

}
