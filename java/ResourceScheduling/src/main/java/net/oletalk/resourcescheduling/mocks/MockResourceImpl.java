/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.resourcescheduling.mocks;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import net.oletalk.resourcescheduling.RSConstants;
import net.oletalk.resourcescheduling.impl.Resource;
import net.oletalk.resourcescheduling.interfaces.Message;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 *
 * @author colin
 */
public class MockResourceImpl extends Resource {
    
    private Logger log = LoggerFactory.getLogger(MockResourceImpl.class);

    private List<Message> messagesSent;
    
    public MockResourceImpl() {
        super();
        messagesSent = new ArrayList<Message>();
    }
    
    public MockResourceImpl(boolean autoProcess_) { 
        super(autoProcess_);
        messagesSent = new ArrayList<Message>();
    }
    
    public void processMessage(final Message m) {
        log.info("Processing given Message: " + m.toString());
        
            
        Random rand = new Random();

        int secs = rand.nextInt(RSConstants.MAX_PROCESSING_SECONDS);
        try {
            Thread.sleep(secs * 1000);
            System.out.println("MESSAGE: " + m.toString());
        } catch (InterruptedException ex) {
        } finally {
            markComplete(m);
            messagesSent.add(m);
        }
        log.info("Done.  Marking message as complete.");

    }
    
    /* For testing purposes */
    public List<Message> messagesSent() {
        return messagesSent;
    }
}
