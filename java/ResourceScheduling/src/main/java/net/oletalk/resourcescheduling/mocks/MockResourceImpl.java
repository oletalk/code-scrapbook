/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.resourcescheduling.mocks;

import java.util.Random;
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

    public MockResourceImpl() {
        super();
    }
    
    public MockResourceImpl(boolean autoProcess_) { 
        super(autoProcess_);
    }
    
    public void processMessage(final Message m) {
        log.info("Processing given Message: " + m.toString());
        
            
        Random rand = new Random();

        int secs = rand.nextInt(5);
        try {
            Thread.sleep(secs * 1000);
            System.out.println("MESSAGE: " + m.toString());
        } catch (InterruptedException ex) { }
        log.info("Done.  Marking message as complete.");
        markComplete(m);

    }
}
