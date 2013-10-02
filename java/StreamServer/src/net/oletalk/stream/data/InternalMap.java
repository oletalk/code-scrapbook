/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.data;

import java.nio.file.Path;
import java.util.Map;
import java.util.TreeMap;
import java.util.logging.Level;
import java.util.logging.Logger;
import net.oletalk.stream.util.LogSetup;

/**
 * Small data structure to keep song data and be able to return a song given a Path/String/other criteria (TBD)
 * 
 * (Might be refactored out in future.)
 * @author colin
 */
public class InternalMap extends TreeMap<Path,Song> {
        
    private Map<Long,Path> internalkeys;
    private static final Logger LOG = LogSetup.getlog();

    private long counter = 0;
    
    public InternalMap()
    {
        this.counter = 0;
        internalkeys = new TreeMap<>();
    }
    
    @Override
    public Song put(Path p, Song s)
    {
        this.counter++; // or however you want to produce a unique internal id
        internalkeys.put(counter, p);
        s.setId(counter);
        //LOG.log(Level.FINE, "Adding song {0} with id {1}", new Object[]{s.toString(), counter});
        return super.put(p, s);
    }
    
    public Song getById(Long l)
    {
        Path p = internalkeys.get(l);
        if (p == null)
        {
            LOG.log(Level.FINE, "Path for song id {0} is null!", l);
        } else {
            if (this.get(p) == null)
            {
                LOG.log(Level.FINE, "Song from path for id {0} is null!", l);
            }
        }
        return (p == null) ? null : this.get(p);
    }
    
    
    
    @Override
    public void putAll(Map<? extends Path, ? extends Song> m)
    {
        for (Path p : m.keySet())
        {
            this.put(p, m.get(p));
        }
    }
}
