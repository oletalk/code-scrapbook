/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.resourcescheduling;

import net.oletalk.resourcescheduling.impl.GatewayImpl;
import net.oletalk.resourcescheduling.impl.MessageImpl;
import net.oletalk.resourcescheduling.mocks.MockResourceImpl;
import org.junit.Ignore;
import org.junit.Test;

/**
 *
 * @author colin
 */
public class SchedulingIntegration {
        @Test @Ignore
    public void testSendMessage() {
        // setup a Gateway and a Resource
        GatewayImpl gateway = new GatewayImpl();
        MockResourceImpl res = new MockResourceImpl(true); // let the resource process the message as soon as it's ready
        gateway.addResource(res);
        
        // setup a new ResourceScheduler with them
        ResourceScheduler rs = new ResourceScheduler(1);
        rs.setGateway(gateway);
        
        // send one message
        rs.sendOrQueueMessage(new MessageImpl("hello there", 1));
        rs.processQueuedMessages(); // shouldn't really be any, but...
    }
    
    @Test @Ignore
    public void testSend2Messages() {
        // setup a Gateway and a Resource
        GatewayImpl gateway = new GatewayImpl();
        MockResourceImpl res = new MockResourceImpl(true); // let the resource process the message as soon as it's ready
        gateway.addResource(res);
        
        // setup a new ResourceScheduler with them
        ResourceScheduler rs = new ResourceScheduler(1);
        rs.setGateway(gateway);
        
        // send one message
        rs.sendOrQueueMessage(new MessageImpl("hello there", 1));
        rs.sendOrQueueMessage(new MessageImpl("hello again", 1));
        rs.processQueuedMessages();
    }

    @Test
    public void testSend4Messages() {
        // setup a Gateway and a Resource
        GatewayImpl gateway = new GatewayImpl();
        MockResourceImpl res = new MockResourceImpl(true); // let the resource process the message as soon as it's ready
        gateway.addResource(res);
        
        // setup a new ResourceScheduler with them
        ResourceScheduler rs = new ResourceScheduler(1);
        rs.setGateway(gateway);
        
        // send 4 messages in 3 groups
        rs.sendOrQueueMessage(new MessageImpl("message1", 2));
        rs.sendOrQueueMessage(new MessageImpl("message2", 1));
        rs.sendOrQueueMessage(new MessageImpl("message3", 2));

        rs.sendOrQueueMessage(new MessageImpl("message4", 3));
        rs.processQueuedMessages();
    }

    
}
