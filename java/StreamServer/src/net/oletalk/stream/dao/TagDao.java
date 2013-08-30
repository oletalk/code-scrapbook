/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.dao;

import java.nio.file.Path;
import java.nio.file.Paths;
import javax.sql.DataSource;
import org.springframework.jdbc.core.simple.SimpleJdbcTemplate;
import java.sql.ResultSet;
import java.sql.SQLException;
import net.oletalk.stream.data.Tag;
import net.oletalk.stream.util.Util;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.RowMapper;
/**
 *
 * @author colin
 */
public class TagDao {
    DataSource dataSource;
    SimpleJdbcTemplate jdbcTemplate;

    @Autowired
    public void setDataSource(DataSource dataSource) {
        this.dataSource = dataSource;
        jdbcTemplate = new SimpleJdbcTemplate(dataSource);
    }
    
    /**
     * Saves audio tag info to the database.
     * 
     * @param tag The Tag object for the song
     */
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
    
    /**
     * Fetches tag info from the database, if it's there.
     * 
     * @param filehash The generated MD5 hash of the audio file.
     * @return a Tag object with this file hash
     */
    public Tag getTag(String filehash)
    {
        return jdbcTemplate.queryForObject(
                "SELECT song_filepath, file_hash, artist, title, secs " +
                "FROM MP3S_jtags where file_hash = ?",
                new TagRowMapper(), filehash
        );
    }
    public Tag getTagFromPath(Path path)
    {
        return jdbcTemplate.queryForObject(
                "SELECT song_filepath, file_hash, artist, title, secs " +
                "FROM MP3S_jtags where song_filepath = ?",
                new TagRowMapper(), path.toString()
        );
    }

    public void recordFailedTag(Path p, String reason) {

        // compute the md5 sum
        String md5 = Util.computeMD5(p);

        // check if there isn't already a failed attempt in there
        try {
            Integer check = jdbcTemplate.queryForObject(
                    "SELECT 1 FROM MP3S_failedtags where file_hash = ?", Integer.class, md5);

        } catch (EmptyResultDataAccessException erdae) {
            // save to MP3S_failedtags for the md5sum
            jdbcTemplate.update(
                    "INSERT INTO MP3S_failedtags (file_hash, reason) " +
                    "VALUES (?, ?)", 
                    md5, reason
            );            
                        
        }
        
    }
    
    
    
    class TagRowMapper implements RowMapper<Tag>
    {

        @Override
        public Tag mapRow(ResultSet rs, int i) throws SQLException {
                        Tag t = new Tag();
                        t.setFilehash(rs.getString("file_hash"));
                        t.setFilepath(Paths.get(rs.getString("song_filepath")));
                        t.setArtist(rs.getString("artist"));
                        t.setTitle(rs.getString("title"));
                        t.setSecs(rs.getInt("secs"));
                        return t;
        }
        
    }

}
