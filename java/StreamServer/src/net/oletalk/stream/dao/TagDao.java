/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.dao;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Map;
import net.oletalk.stream.data.Song;
import net.oletalk.stream.data.Tag;
import net.oletalk.stream.util.Util;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.RowMapper;
/**
 *
 * @author colin
 */
public class TagDao extends BasicDao<Tag> {

    /**
     * Saves audio tag info to the database.
     * 
     * @param tag The Tag object for the song
     */
    @Override
    public void save(Tag t) {
        jdbcTemplate.update(
                "DELETE FROM MP3S_jtags WHERE song_id = ?", 
                t.getSong_id()
                );
        
        jdbcTemplate.update(
                "INSERT INTO MP3S_jtags (song_id, artist, title, secs) " +
                "VALUES (?, ?, ?, ?)", 
                t.getSong_id(),
                t.getArtist(),
                t.getTitle(),
                t.getSecs()
        );

    }

    public Tag get(Map<String, Object> args) {
        
        String sql = "SELECT song_id, artist, title, secs FROM MP3S_jtags";
        return super.get(sql, new TagRowMapper(), args);
    }

    /**
     * Fetches tag info from the database, if it's there.
     * 
     * @param filehash The generated MD5 hash of the audio file.
     * @return a Tag object with this file hash
     */

    public Tag getTagFromSong(Song song)
    {
        return get(mapFrom("song_id", song.getId()));
    }
    
    public void recordFailedTag(Song s, String reason) {

        // compute the md5 sum
        String md5 = Util.computeMD5(s.getPath());

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
                        t.setSong_id(rs.getLong("song_id"));
                        t.setArtist(rs.getString("artist"));
                        t.setTitle(rs.getString("title"));
                        t.setSecs(rs.getInt("secs"));
                        return t;
        }
        
    }

}
