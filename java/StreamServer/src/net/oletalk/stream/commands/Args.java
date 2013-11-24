/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.commands;

import net.oletalk.stream.actor.Downsampler;
import net.oletalk.stream.actor.StatsCollector;
import net.oletalk.stream.data.SongList;

/**
 *
 * @author colin
 */
public class Args {
    
    private String uri;
    private SongList list;
    
    // Drop command stuff
    private String hostheader;
    
    // Play command stuff
    private boolean downsample;
    private Downsampler downsampler;
    private Integer buffersize;
    
    // Common objects
    private StatsCollector collector;
    

    public String getUri() {
        return uri;
    }

    public void setUri(String uri) {
        this.uri = uri;
    }

    public SongList getList() {
        return list;
    }

    public void setList(SongList list) {
        this.list = list;
    }

    public String getHostheader() {
        return hostheader;
    }

    public void setHostheader(String hostheader) {
        this.hostheader = hostheader;
    }

    public boolean isDownsample() {
        return downsample;
    }

    public void setDownsample(boolean downsample) {
        this.downsample = downsample;
    }

    public Downsampler getDownsampler() {
        return downsampler;
    }

    public void setDownsampler(Downsampler downsampler) {
        this.downsampler = downsampler;
        setDownsample(this.downsampler != null);
    }

    public Integer getBuffersize() {
        return buffersize;
    }

    public void setBuffersize(Integer buffersize) {
        this.buffersize = buffersize;
    }

    public StatsCollector getCollector() {
        return collector;
    }

    public void setCollector(StatsCollector collector) {
        this.collector = collector;
    }
    
}
