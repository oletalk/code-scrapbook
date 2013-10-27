/*
 * Utility class to create a new tag (using jaudiotagger and MessageDigest) given a path.
 */
package net.oletalk.stream.actor;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import net.oletalk.stream.dao.TagDao;
import net.oletalk.stream.data.Song;
import net.oletalk.stream.data.Tag;
import net.oletalk.stream.util.LogSetup;
import net.oletalk.stream.util.Stopwatch;
import org.jaudiotagger.audio.AudioFile;
import org.jaudiotagger.audio.AudioFileIO;
import org.jaudiotagger.audio.AudioHeader;
import org.jaudiotagger.audio.exceptions.CannotReadException;
import org.jaudiotagger.audio.exceptions.InvalidAudioFrameException;
import org.jaudiotagger.audio.exceptions.ReadOnlyFileException;
import org.jaudiotagger.tag.FieldKey;
import org.jaudiotagger.tag.TagException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;

/**
 *
 * @author colin
 */
public class TagReader {
    
    private static final Logger LOG = LogSetup.getlog();

    @Autowired
    private TagDao td;
            
    public Tag get(Song s)
    {
        Tag t = getFromDB(s);
        
        if (t == null)
        {
            try {
                t = getFromFileSystem(s);
                // save off to the db
                if (t != null)
                {
                    td.save(t);                
                } else {
                    td.recordFailedTag(s, "No tag found within file");
                    LOG.log(Level.WARNING, "Still couldn't find tag for song");
                }
            } catch (TagException te) {
                String errMsg = (te.getCause() != null ? te.getCause().getMessage() : te.getMessage() );
                errMsg = errMsg.substring(0, Math.min(99, errMsg.length()));
                td.recordFailedTag(s, errMsg);
            }
        }
        // and return
        return t;
    }
    
    public List<Tag> getFromDB(List<Song> songs)
    {
        LOG.log(Level.FINE, "Looking for Tag info from the database for {0} song(s).", songs.size());
        List<Tag> tags = null;
        try {
            tags = td.getTags(songs);            
        } catch (EmptyResultDataAccessException erd) {
            LOG.log(Level.FINE, "No tag info found for any of the songs!");
        }
        return tags;
        
    }
    
    public Tag getFromDB(Song s)
    {
        LOG.log(Level.FINE, "Looking for Tag info from the database.");
        Tag t = null;
        try {
            t = td.getTagFromSong(s);
        } catch (EmptyResultDataAccessException erd) {
            LOG.log(Level.FINE, "No tag info found in db for file");
        }
        return t;
    }
    
    public Tag getFromFileSystem(Song s) throws TagException
    {
        Tag t = null;
        LOG.log(Level.FINE, "Looking for Tag info from the file itself.");
        // Create a new Tag object using file info/md5sum/id3 tags
        try {
            Stopwatch st = new Stopwatch(true);
            AudioFile f = AudioFileIO.read(new File(s.getPath().toString())); // TODO - sometimes the tagger misses the file
            AudioHeader hdr = f.getAudioHeader();
            org.jaudiotagger.tag.Tag audiotag = f.getTag();
            
            // if we have a tag, populate and return the object; otherwise return null
            if (audiotag != null) {
                t = new Tag();
                t.setArtist(audiotag.getFirst(FieldKey.ARTIST));
                t.setTitle(audiotag.getFirst(FieldKey.TITLE));
                t.setSong_id(s.getId());
                t.setSecs(hdr.getTrackLength());
                //t.setFilehash(Util.computeMD5(p)); // CM 4/10/2013 this is going up to song level now
                LOG.log(Level.FINE, "Created Tag for ''{0} in {1}ms.", 
                        new Object[]{s.getPath().toString(), st.elapsedTime()});
            } else {
                LOG.log(Level.FINE, "No tag found for {0}", s.getPath().toString());
            }
        } catch (FileNotFoundException fnfe) {
            // most likely because JAudioTagger's file check failed on weird characters :-/
            LOG.log(Level.WARNING, "3rd-party tagger couldn't find the file");
            throw new TagException("3rd-party tagger couldn't find the file");
            
        } catch (CannotReadException | IOException | TagException | ReadOnlyFileException | InvalidAudioFrameException ex) {
            LOG.log(Level.SEVERE, "Problems creating new Tag from the file", ex);
            throw new TagException("Problems creating new Tag from the file", ex);
        }
        return t;
    }

}
