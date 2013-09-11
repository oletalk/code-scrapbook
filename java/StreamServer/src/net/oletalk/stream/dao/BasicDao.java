/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.dao;

import javax.sql.DataSource;
import org.springframework.jdbc.core.simple.SimpleJdbcTemplate;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.RowMapper;
/**
 *
 * @author colin
 */
public abstract class BasicDao<T> {
    DataSource dataSource;
    SimpleJdbcTemplate jdbcTemplate;

    @Autowired
    public void setDataSource(DataSource dataSource) {
        this.dataSource = dataSource;
        jdbcTemplate = new SimpleJdbcTemplate(dataSource);
    }
    
    public abstract void save(T t);
    
    public T get(String sql, RowMapper<T> rowmapper, Map<String, Object> args) {
        if (args.keySet() != null)
            sql += whereClause(args);
        return jdbcTemplate.queryForObject(sql, rowmapper, args.values().toArray());
    }

    
    // Utility methods
    
    protected Map<String,Object> mapFrom(String s, Object o)
    {
        Map<String,Object> m = new HashMap<>();
        m.put(s, o);
        return m;
    }
    
    protected String whereClause(Map<String,Object> criteria)
    {
        StringBuilder sb = new StringBuilder();
        if (criteria != null && !criteria.isEmpty())
        {
            boolean firstArg = true;
            for (String s : criteria.keySet())
            {
                sb.append(firstArg ? " WHERE " : " AND ");
                firstArg = false;
                sb.append(s).append(" = ?");
            }
        }
        return sb.toString();
    }
    
}
