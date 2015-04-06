/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.resourcescheduling.impl;

import net.oletalk.resourcescheduling.interfaces.Message;

/**
 * Wrapper class for 3rd-party Resource based on exercise requirements.
 * Assumes the resource handles one message at a time (queuing happens
 * on the client side)
 * 
 * @author colin
 */
public abstract class Resource {

    private boolean available;
    private boolean autoProcess; // set to false here to allow testing
    
    public Resource() {
        available = true;
        autoProcess = false;
    }
    
    public Resource(boolean autoProcess_) {
        available = true;
        autoProcess = autoProcess_;
    }
    
    public void markComplete(Message msg) {
        msg.completed();
        available = true;
    }
    
    // This is the call-out to your 3rd-party resource
    protected abstract void processMessage(Message msg);
    
    public void process(final Message msg) {
        Thread t = new Thread() {
            @Override
            public void run() {
                processMessage(msg);                
            }
        };
                
        t.start();
    }
    
    public void receive(Message msg) throws IllegalStateException {
        if (available) {
            available = false;
            if (autoProcess) {
                process(msg);
            }
        } else {
            throw new IllegalStateException("Resource is still busy, try again later");
        }
    }
    public boolean isAvailable() {
        return available;
    }
    
    
    
}
