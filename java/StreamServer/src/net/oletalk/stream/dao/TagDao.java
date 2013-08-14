/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.dao;

import java.nio.file.Paths;
import javax.sql.DataSource;
import org.springframework.jdbc.core.simple.SimpleJdbcTemplate;
import java.sql.ResultSet;
import java.sql.SQLException;
import net.oletalk.stream.data.Tag;
import org.springframework.jdbc.core.RowMapper;
/**
 *
 * @author colin
 */
public class TagDao {
    DataSource dataSource;
    SimpleJdbcTemplate jdbcTemplate;

    public void setDataSource(DataSource dataSource) {
        this.dataSource = dataSource;
        jdbcTemplate = new SimpleJdbcTemplate(dataSource);
    }
    
    public void saveTag(Tag tag)
    {
        jdbcTemplate.update(
                "DELETE FROM MP3S_jtags WHERE file_hash = ?", 
                tag.getFilehash()
                );
        
        jdbcTemplate.update(
                "INSERT INTO MP3S_jtags (song_filepath, file_hash, artist, title, secs) " +
                "VALUES (?, ?, ?, ?, ?)", 
                tag.getFilepath().toString(),
                tag.getFilehash(),
                tag.getArtist(),
                tag.getTitle(),
                tag.getSecs()
        );
    }
    
    public Tag getTag(String filehash)
    {
        return jdbcTemplate.queryForObject(
                "SELECT song_filepath, file_hash, artist, title, secs " +
                "FROM MP3S_jtags where file_hash = ?",
                new RowMapper<Tag>() {
                    public Tag mapRow(ResultSet rs, int rowNum) throws SQLException {
                        Tag t = new Tag();
                        t.setFilehash(rs.getString("file_hash"));
                        t.setFilepath(Paths.get(rs.getString("song_filepath")));
                        t.setArtist(rs.getString("artist"));
                        t.setTitle(rs.getString("title"));
                        t.setSecs(rs.getInt("secs"));
                        return t;
                    }
                },
                filehash
        );
    }

}
