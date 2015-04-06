/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.resourcescheduling;

import java.util.TreeSet;
import net.oletalk.resourcescheduling.impl.MessageImpl;
import org.junit.Test;
import static org.junit.Assert.*;


/**
 *
 * @author colin
 */
public class InnerQueueTest {

    @Test
    public void testOneInsert() {
        InnerQueue q = new InnerQueue();
        q.insertMessage(new MessageImpl("hello", 1));
        assertFalse(q.getActiveGroups().isEmpty());
    }
    
    @Test
    public void testInsertsDifferentGroups() {
        InnerQueue q = new InnerQueue();
        q.insertMessage(new MessageImpl("hello", 1));
        q.insertMessage(new MessageImpl("hello", 3));
        assertEquals(q.getActiveGroups().size(), 2);
    }
    
    @Test
    public void testInsertsSameGroups() {
        InnerQueue q = new InnerQueue();
        q.insertMessage(new MessageImpl("hello", 1));
        q.insertMessage(new MessageImpl("foobar", 1));
        assertEquals(q.getActiveGroups().size(), 1);
    }
    
    @Test
    public void testInsertRetrieval() {
        InnerQueue q = new InnerQueue();
        q.insertMessage(new MessageImpl("hello", 1));
        MessageImpl m = q.getMessage();
        assertNotNull(m);
        assertEquals(m.getGroupId(), 1);
        assertNull("Shouldn't have any more messages in the queue", q.getMessage());
    }
    
    @Test
    public void testMultipleRetrieval() {
        InnerQueue q = new InnerQueue();
        q.insertMessage(new MessageImpl("hello", 1));
        q.insertMessage(new MessageImpl("foobar", 2));
        q.insertMessage(new MessageImpl("something",2));
        assertEquals(q.getActiveGroups().size(), 2);
        TreeSet<String> messageContents = new TreeSet<String>();
        
        MessageImpl m;
        int ctr = 0;
        while ((m = q.getMessage()) != null) {
            messageContents.add(m.getContent());
            ctr++;
        }
        
        assertEquals("Should have contained 3 messages", ctr, 3);
        String[] expected = {"foobar", "hello", "something"};
        assertEquals(expected, messageContents.toArray());
    }


}
