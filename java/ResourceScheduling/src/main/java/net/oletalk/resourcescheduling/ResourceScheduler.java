/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.resourcescheduling;

import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import net.oletalk.resourcescheduling.impl.GatewayImpl;
import net.oletalk.resourcescheduling.impl.MessageImpl;
import net.oletalk.resourcescheduling.interfaces.Message;
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
    
    public ResourceScheduler(int numResourcesAvailable) {
        this.setNumResources(numResourcesAvailable);
    }
    
    public void sendOrQueueMessage(MessageImpl msg) {
        // MessageImpl because processing needs to know about the group id which the interface doesn't have
        Integer groupId = new Integer(msg.getGroupId());
        
        // Needs to know if any resources are available
        if (gateway.anyResourcesAvailable()) {
            gateway.send(msg);
        } else {
            innerQueue.insertMessage(msg);
        }
        
        // if so, for EACH available resource, check if you have a message whose group id matches that of the last message you sent to that resource
        // do we have a match? send it to the Gateway
        // no match? we have an idle resource, send SOMEthing to the Gateway
        
        // mark the message with the appropriate routing info so the Gateway will forward it on to the appropriate Resource.
        
    }
    
    
    public final void setNumResources(int numResources_) {
        this.numResources = numResources_;
    }
    
    public int getNumResources() {
        return numResources;
    }

    public void completed(int groupId) {
        
    }
}
