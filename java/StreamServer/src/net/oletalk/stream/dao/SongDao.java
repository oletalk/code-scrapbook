/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.dao;

import java.nio.file.Paths;
import java.sql.ResultSet;
import java.sql.SQLException;
import net.oletalk.stream.data.Song;
import net.oletalk.stream.util.Util;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.RowMapper;

/**
 *
 * @author colin
 */
public class SongDao extends BasicDao<Song> {

    public Song get(String filehash)
    {
        String sql = "SELECT id, file_hash, song_filepath FROM MP3S_jsongs";
        return get(sql, new SongRowMapper(), mapFrom("file_hash", filehash));
    }
    
    public Song get(long id)
    {
        String sql = "SELECT id, file_hash, song_filepath FROM MP3S_jsongs";
        return get(sql, new SongRowMapper(), mapFrom("id", id));
    }
    
    @Override
    public void save(Song t) {
        saved(t);
    }
    
    public int saved(Song t) {
        
        int ret;
        
        if (t.getFilehash() == null)
        {
            t.setFilehash(Util.computeMD5(t.getPath().toString()));
        }
        
        try {
        Integer count = jdbcTemplate.queryForInt(
                "SELECT 1 FROM MP3S_jsongs WHERE file_hash = ?", 
                t.getFilehash());
            // if exists, update the row
            jdbcTemplate.update(
                "UPDATE MP3S_jsongs SET song_filepath = ? WHERE file_hash = ?",
                t.getPath().toString(),
                t.getFilehash());
                        
        } catch (EmptyResultDataAccessException erdae) {
            // if doesn't exist, insert a new row
            jdbcTemplate.update(
                    "INSERT INTO MP3S_jsongs (file_hash, song_filepath) " +
                    "VALUES (?, ?)", 
                    t.getFilehash(),
                    t.getPath().toString()
            );
            
        }
        
        // return internal id
        ret = jdbcTemplate.queryForInt(
            "SELECT id FROM MP3S_jsongs WHERE file_hash = ?",
            t.getFilehash());
        
        return ret;
    }
    
    
    class SongRowMapper implements RowMapper<Song>
    {

        @Override
        public Song mapRow(ResultSet rs, int i) throws SQLException {
                        String sfp = rs.getString("song_filepath");
                        Song t = new Song(Paths.get(sfp));
                        t.setId(rs.getLong("id"));
                        t.setFilehash(rs.getString("file_hash"));
                        return t;
        }
        
    }

}
