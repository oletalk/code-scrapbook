/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.mp3s.dao;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.sql.DataSource;
import net.oletalk.mp3s.data.TagInfo;
import org.springframework.jdbc.core.simple.ParameterizedRowMapper;
import org.springframework.jdbc.core.simple.SimpleJdbcTemplate;

/**
 *
 * @author colin
 */
public class TagDAO {
    DataSource dataSource;
    SimpleJdbcTemplate jdbcTemplate;
    
    public void setDataSource(DataSource ds) {
        this.dataSource = ds;
        jdbcTemplate = new SimpleJdbcTemplate(ds);
    }
    
    public List<Object> getEmptyTags() {
        System.out.println("GET EMPTY TAGS!");
        String sql = "select song_filepath, file_hash, artist, title, secs from mp3s_tags where artist is NULL";
        return this.jdbcTemplate.query(sql, this.getMapper(), new HashMap());
    }
    
    public TagInfo getTagInfo(final String filepath) {
        String sql = "select song_filepath, file_hash, artist, title, secs from mp3s_tags where song_filepath = ?";
        return this.jdbcTemplate.queryForObject(sql, this.getMapper(), filepath);
    }
    
    private ParameterizedRowMapper<TagInfo> getMapper() {
        return new ParameterizedRowMapper<TagInfo>() {
          public TagInfo mapRow(ResultSet rs, int rowNum) throws SQLException {
              TagInfo taginfo = new TagInfo();
              taginfo.setSongFilepath(rs.getString("song_filepath"));
              taginfo.setFilehash(rs.getString("file_hash"));
              taginfo.setArtist(rs.getString("artist"));
              taginfo.setTitle(rs.getString("title"));
              taginfo.setSecs(rs.getInt("secs"));
              System.out.println(taginfo.toString());
              return taginfo;
          }  
        };
    }
}
