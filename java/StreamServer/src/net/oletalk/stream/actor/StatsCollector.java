/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.actor;

import java.nio.file.Path;
import java.util.List;
import net.oletalk.stream.dao.StatsDao;
import net.oletalk.stream.data.Stats;
import net.oletalk.stream.interfaces.HTMLRepresentable;
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

    public String fetchStats(String category, String item)
    {
        StringBuilder sb = new StringBuilder();
        List<Stats> allstats = sd.get(category, item);
        String header = "";
        if (allstats.isEmpty())
        {
            sb.append("<h2>No stats found</h2>");
        }
        else {
            for (Stats s : allstats)
            {
                String cat = s.getCategory();
                if (!header.equals(cat))
                {
                    sb.append("<h2>").append(cat).append("</h2>\n");
                    header = cat;
                }
                sb.append(s.getItem()).append(": ").append(s.getCount()).append("<br/>\n");
            }
            
        }
        
        return sb.toString();
    }
    
}
