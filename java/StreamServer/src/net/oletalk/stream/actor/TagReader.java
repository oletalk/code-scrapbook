/*
 * Utility class to create a new tag (using jaudiotagger and MessageDigest) given a path.
 */
package net.oletalk.stream.actor;

import java.io.File;
import java.io.IOException;
import java.nio.file.Path;
import java.util.logging.Level;
import java.util.logging.Logger;
import net.oletalk.stream.dao.TagDao;
import net.oletalk.stream.data.Tag;
import net.oletalk.stream.util.LogSetup;
import net.oletalk.stream.util.Stopwatch;
import net.oletalk.stream.util.Util;
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

    private TagDao td;
    
    @Autowired
    public void setTagDao(TagDao tagdao)
    {
        td = tagdao;
    }
        
    public Tag get(Path p)
    {
        Tag t = getFromDB(p);
        
        if (t == null)
        {
            try {
                t = getFromFileSystem(p);
                // save off to the db
                if (t != null)
                {
                    td.saveTag(t);                
                } else {
                    td.recordFailedTag(p, "No tag found within file");
                    LOG.log(Level.WARNING, "Still couldn't find tag for song");
                }
            } catch (TagException te) {
                String errMsg = te.getCause().getMessage();
                errMsg = errMsg.substring(0, Math.min(100, errMsg.length()));
                td.recordFailedTag(p, errMsg);
            }
        }
        // and return
        return t;
    }
    
    public Tag getFromDB(Path p)
    {
        LOG.log(Level.FINE, "Looking for Tag info from the database.");
        Tag t = null;
        try {
            t = td.getTagFromPath(p);
        } catch (EmptyResultDataAccessException erd) {
            LOG.log(Level.FINE, "No tag info found in db for file");
        }
        return t;
    }
    
    public Tag getFromFileSystem(Path p) throws TagException
    {
        Tag t = null;
        LOG.log(Level.FINE, "Looking for Tag info from the file itself.");
        // Create a new Tag object using file info/md5sum/id3 tags
        try {
            Stopwatch st = new Stopwatch(true);
            AudioFile f = AudioFileIO.read(new File(p.toString()));
            AudioHeader hdr = f.getAudioHeader();
            org.jaudiotagger.tag.Tag audiotag = f.getTag();
            
            // if we have a tag, populate and return the object; otherwise return null
            if (audiotag != null) {
                t = new Tag();
                t.setArtist(audiotag.getFirst(FieldKey.ARTIST));
                t.setTitle(audiotag.getFirst(FieldKey.TITLE));
                t.setFilepath(p);
                t.setSecs(hdr.getTrackLength());
                t.setFilehash(Util.computeMD5(p));
                LOG.log(Level.FINE, "Created Tag for ''{0} in {1}ms.", 
                        new Object[]{p.toString(), st.elapsedTime()});
            } else {
                LOG.log(Level.FINE, "No tag found for {0}", p.toString());
            }
        } catch (CannotReadException | IOException | TagException | ReadOnlyFileException | InvalidAudioFrameException ex) {
            LOG.log(Level.SEVERE, "Problems creating new Tag from the file", ex);
            throw new TagException("Problems creating new Tag from the file", ex);
        }
        return t;
    }

}
