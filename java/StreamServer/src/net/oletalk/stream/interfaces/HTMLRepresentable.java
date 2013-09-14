/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.interfaces;

import java.nio.file.Path;

/**
 *
 * @author colin
 */
public interface HTMLRepresentable {
    
    public String asHTML(Path rootpath);
            
}
