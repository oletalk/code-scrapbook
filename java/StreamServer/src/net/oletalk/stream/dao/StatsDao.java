/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.dao;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import net.oletalk.stream.data.Stats;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.RowMapper;

/**
 *
 * @author colin
 */
public class StatsDao extends BasicDao<Stats> {

    public List<Stats> get(String category, String item)
    {
        HashMap<String,Object> args = new HashMap<>();
        if (category != null)
        {
            args.put("category", category);
            if (item != null) {
                args.put("item", item);            
            }
        }
        List<String> olist = Arrays.asList(new String[]{"1", "2", "3 desc"});
        
        return getAll("SELECT category, item, count FROM MP3S_jstats", new StatsRowMapper(), args, olist);
    }
    
    @Override
    public void save(Stats t) {
        
        try {
        Integer count = jdbcTemplate.queryForInt(
                "SELECT count FROM MP3s_jstats WHERE category = ? AND item = ?", 
                t.getCategory(),
                t.getItem());
            // if exists, update the row
            jdbcTemplate.update(
                "UPDATE MP3s_jstats SET count = count + 1 WHERE category = ? AND item = ?",
                t.getCategory(),
                t.getItem());
            
        } catch (EmptyResultDataAccessException erdae) {
            // if doesn't exist, insert a new row
            jdbcTemplate.update(
                    "INSERT INTO MP3S_jstats (category, item) " +
                    "VALUES (?, ?)", 
                    t.getCategory(),
                    t.getItem()
            );
            
        }
    }
    
    class StatsRowMapper implements RowMapper<Stats>
    {

        @Override
        public Stats mapRow(ResultSet rs, int i) throws SQLException {
                        Stats t = new Stats();
                        t.setCategory(rs.getString("category"));
                        t.setItem(rs.getString("item"));
                        t.setCount(rs.getInt("count"));
                        return t;
        }
        
    }
}
