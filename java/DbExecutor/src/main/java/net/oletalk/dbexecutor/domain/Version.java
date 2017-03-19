/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.dbexecutor.domain;

import java.util.List;
import net.oletalk.dbexecutor.RolloutType;

/**
 *
 * @author colin
 */
public class Version {
    private List<String> filenames;
    private RolloutType type;

    public Version(RolloutType type) {
        this.type = type;
    }
    
    public RolloutType getType() {
        return type;
    }

    public void setType(RolloutType type) {
        this.type = type;
    }
    
    public List<String> getFilenames() {
        return filenames;
    }

    public void setFilenames(List<String> filenames) {
        this.filenames = filenames;
    }
    
    
}
