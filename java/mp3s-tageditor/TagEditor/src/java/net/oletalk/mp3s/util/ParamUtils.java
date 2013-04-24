/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.mp3s.util;

/**
 *
 * @author colin
 */
public class ParamUtils {
    public static int parseOrZero (String num) {
        int ret = 0;
        try {
            ret = Integer.parseInt(num);
        } catch (NumberFormatException nfe) {}
        return ret;
    }
}
