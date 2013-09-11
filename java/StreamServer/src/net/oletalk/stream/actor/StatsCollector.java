/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.actor;

import net.oletalk.stream.dao.StatsDao;
import net.oletalk.stream.data.Stats;
import org.springframework.beans.factory.annotation.Autowired;

/**
 *
 * @author colin
 */
public class StatsCollector {
    
    @Autowired
    private StatsDao sd;
    
    public void countStat(String category, String item)
    {
        Stats st = new Stats();
        st.setCategory(category);
        st.setItem(item);
        sd.save(st);
    }
    
}
