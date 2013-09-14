/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.dao;

import java.util.List;
import java.util.Map;
import net.oletalk.stream.util.Util;

/**
 *
 * @author colin
 */
public class QueryDetails {
    private String sql;
    private List<String> orderby;
    private Map<String, Object> criteria;
    
    public QueryDetails(String sql)
    {
        this.sql = sql;
    }
    
    public QueryDetails(String sql, Map<String, Object> criteria) {
        this.sql = sql;
        this.criteria = criteria;
    }
    
    public QueryDetails(String sql, Map<String, Object> criteria, List<String> orderby) {
        this.sql = sql;
        this.criteria = criteria;
        this.orderby = orderby;
    }
    
    public Object[] getQueryArgs()
    {
        if (criteria != null && !criteria.isEmpty())
        {
            return criteria.values().toArray();
        }
        else {
            return null;
        }
    }
    
    public String getOrderByClause()
    {
        StringBuilder sb = new StringBuilder();
        if (orderby != null && !orderby.isEmpty())
        {
            sb.append(" ORDER BY ").append(Util.join(orderby, ","));
        }
        return sb.toString();
    }
    
    @Override
    public String toString()
    {
        StringBuilder sb = new StringBuilder(sql);
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
        
        sb.append(getOrderByClause());
        return sb.toString();
    }
    

}
