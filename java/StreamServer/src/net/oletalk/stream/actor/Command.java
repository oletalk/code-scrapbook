/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.actor;

import java.util.EnumSet;
import java.util.HashMap;
import java.util.Map;

/**
 *
 * @author colin
 */
public class Command {

    public enum Type { 
        // add your new command type in here
        // and don't forget to add it into the *Handler that handles this type of Command
        PLAY("play"), 
        LIST("list"), 
        DROP("drop"), 
        STATS("stats"), 
        SEARCH("search");
        
        private String value;
        
        Type (String val) {
            this.value = val;
        }
        
        private static final Map<String,Type> lookup = new HashMap<>();
        
        static {
            for (Type t : EnumSet.allOf(Type.class)) {
                lookup.put(t.toString(), t);
            }
        }
        
        public static Type get(String value) {
            return lookup.get(value);
        }
        
        @Override
        public String toString() {
            return this.value;
        }
    }
    
}
