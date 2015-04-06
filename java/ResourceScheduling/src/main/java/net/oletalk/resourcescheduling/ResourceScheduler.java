/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.resourcescheduling;

import net.oletalk.resourcescheduling.impl.GatewayImpl;
import net.oletalk.resourcescheduling.impl.MessageImpl;
import net.oletalk.resourcescheduling.interfaces.MessageListener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 *
 * @author colin
 */
public class ResourceScheduler implements MessageListener {
    
    private Logger log = LoggerFactory.getLogger(ResourceScheduler.class);
    private int numResources;
    private InnerQueue innerQueue;
    private GatewayImpl gateway;
    private Integer preferredGroup;
    
    public ResourceScheduler(int numResourcesAvailable) {
        this.setNumResources(numResourcesAvailable);
        innerQueue = new InnerQueue();
    }
    
    public void setGateway(GatewayImpl gateway_) {
        this.gateway = gateway_;
    }
    
    public void processQueuedMessages() {
        log.info("Processing queued messages.");
        MessageImpl m;
        do {
            if (preferredGroup != null) {
                log.info("Preferred group id " + preferredGroup + " was specified, so we'll try to fetch one of it.");
                m = innerQueue.getMessageFromGroups(preferredGroup);
                if (m == null) {
                    log.info("Group for preferred group id was empty so we'll just fetch any message.");
                    m = innerQueue.getMessage();
                }
            } else {
                m = innerQueue.getMessage();
                if (m != null) {
                    log.info("Fetched queued message.");
                    while (!gateway.anyResourcesAvailable()) {
                        try {
                            Thread.sleep(1000);
                        } catch (InterruptedException ex) {}
                    }
                    log.info("Gateway has become available, sending queued message.");
                    gateway.send(m);
                }
            }
            try {
                Thread.sleep(1000);
            } catch (InterruptedException ex) {}
        } while (m != null);
        log.info("Inner queue is now empty; processing stopped.");
    }
    
    public void sendOrQueueMessage(MessageImpl msg) {
        log.info("Requested to send/queue message.");
        // MessageImpl because processing needs to know about the group id which the interface doesn't have
        Integer groupId = new Integer(msg.getGroupId());
        
        // Needs to know if any resources are available
        if (gateway.anyResourcesAvailable()) {
            log.info("At least one resource is available, so sending the message on.");
            gateway.send(msg);
        } else {
            log.info("No resources available; queuing message.");
            innerQueue.insertMessage(msg);
        }
        log.info("Sending/queuing message complete!");        
    }
    
    
    public final void setNumResources(int numResources_) {
        this.numResources = numResources_;
    }
    
    public int getNumResources() {
        return numResources;
    }

    public void completed(int groupId) {
        preferredGroup = new Integer(groupId);
    }
}
