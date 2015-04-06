/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.resourcescheduling;

import net.oletalk.resourcescheduling.impl.GatewayImpl;
import net.oletalk.resourcescheduling.impl.MessageImpl;
import net.oletalk.resourcescheduling.interfaces.Message;
import net.oletalk.resourcescheduling.mocks.MockResourceImpl;
import org.junit.Ignore;
import org.junit.Test;
import static org.junit.Assert.*;
import org.junit.Before;

/**
 *
 * @author colin
 */
public class SchedulingIntegrationTest {

    private GatewayImpl gateway;
    private MockResourceImpl res;
    private ResourceScheduler rs;
    
    @Before
    public void setUp() {
        // setup a Gateway and a Resource
        gateway = new GatewayImpl();
        res = new MockResourceImpl(true); // let the resource process the message as soon as it's ready
        gateway.addResource(res);
        
        // setup a new ResourceScheduler with them
        rs = new ResourceScheduler(1);
        rs.setGateway(gateway);

    }
    
    
    @Test
    public void testSendMessage() {
        
        // send one message
        rs.sendOrQueueMessage(new MessageImpl("hello there", 1));
        rs.processQueuedMessages(); // shouldn't really be any, but...
    }
    
    @Test
    public void testSend2Messages() {
        // send one message
        rs.sendOrQueueMessage(new MessageImpl("hello there", 1));
        rs.sendOrQueueMessage(new MessageImpl("hello again", 1));
        rs.processQueuedMessages();
    }

    @Test
    public void testCancelGroup() {
        rs.sendOrQueueMessage(new MessageImpl("foobar", 2));
        rs.sendOrQueueMessage(new MessageImpl("another message", 3));
        rs.cancelGroup(2);
        rs.sendOrQueueMessage(new MessageImpl("bazquux", 2)); // should not be present
        rs.processQueuedMessages();
        assertEquals("Message, content = 'foobar', group id = 2, complete = true" +
                    "Message, content = 'another message', group id = 3, complete = true", allMessages());
    }
    
    @Test
    public void testSendTerminationMessage() {
        rs.sendOrQueueMessage(new MessageImpl("foobar", 2));
        rs.sendOrQueueMessage(new MessageImpl(RSConstants.TERMINATE, 2));
        rs.sendOrQueueMessage(new MessageImpl("another message", 1));
        rs.sendOrQueueMessage(new MessageImpl("bazquux", 2)); // should not be present
        rs.processQueuedMessages();
        assertEquals("Message, content = 'foobar', group id = 2, complete = true" +
                    "Message, content = '" + RSConstants.TERMINATE + "', group id = 2, complete = true" +
                    "Message, content = 'another message', group id = 1, complete = true", allMessages());
    }

    
    @Test
    public void testSend4Messages() {
        // send 4 messages in 3 groups
        rs.sendOrQueueMessage(new MessageImpl("message1", 2));
        rs.sendOrQueueMessage(new MessageImpl("message2", 1));
        rs.sendOrQueueMessage(new MessageImpl("message3", 2));

        rs.sendOrQueueMessage(new MessageImpl("message4", 3));
        rs.processQueuedMessages();
                
        assertEquals("Message, content = 'message1', group id = 2, complete = true" +
                    "Message, content = 'message3', group id = 2, complete = true" +
                    "Message, content = 'message2', group id = 1, complete = true" +
                    "Message, content = 'message4', group id = 3, complete = true"
                    , allMessages());
    }
    
    @Test
    public void testSend4Messages2Resources() {
        
        // add a new Resource
        MockResourceImpl res2 = new MockResourceImpl(true); // let the resource process the message as soon as it's ready
        gateway.addResource(res2);
        
        // send 4 messages in 3 groups
        rs.sendOrQueueMessage(new MessageImpl("message1", 2));
        rs.sendOrQueueMessage(new MessageImpl("message2", 1));
        rs.sendOrQueueMessage(new MessageImpl("message3", 2));

        rs.sendOrQueueMessage(new MessageImpl("message4", 3));
        rs.processQueuedMessages();
        // order is random and we have two resources now, so we'll just test for content for now
        String messages = allMessages() + allMessages(res2);
        assertTrue("First message incorrect or not found", messages.contains("'message1'"));
        assertTrue("Second message incorrect or not found", messages.contains("'message2'"));
        assertTrue("Third message incorrect or not found", messages.contains("'message3'"));
        assertTrue("Fourth message incorrect or not found", messages.contains("'message4'"));
    }

    private String allMessages(MockResourceImpl res2) {
        StringBuilder sb = new StringBuilder();
        
        for (Message m: res2.messagesSent()) {
            sb.append(m.toString());
        }
        return sb.toString();

    }
    private String allMessages() {
        return allMessages(res);
    }
    
}
