/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.dao;

import javax.sql.DataSource;
import org.springframework.jdbc.core.simple.SimpleJdbcTemplate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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
    
    public List<T> getAll(String sql, RowMapper<T> rowmapper, Map<String, Object> args, List<String> orderby) {
        QueryDetails details = new QueryDetails(sql, args, orderby);
        Object[] qargs = details.getQueryArgs();
        String finalsql = details.toString();

        return qargs != null ? jdbcTemplate.query(finalsql, rowmapper, qargs) 
                             : jdbcTemplate.query(finalsql, rowmapper);
        
    }
    
    public T get(String sql, RowMapper<T> rowmapper, Map<String, Object> args) {
        QueryDetails details = new QueryDetails(sql, args);
        
        Object[] qargs = details.getQueryArgs();
        return qargs != null ? jdbcTemplate.queryForObject(details.toString(), rowmapper, qargs)
                             : jdbcTemplate.queryForObject(details.toString(), rowmapper);
    }

    
    // Utility methods
    
    protected Map<String,Object> mapFrom(String s, Object o)
    {
        Map<String,Object> m = new HashMap<>();
        m.put(s, o);
        return m;
    }
    
}
