/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.resourcescheduling.impl;

import net.oletalk.resourcescheduling.mocks.MockResourceImpl;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 *
 * @author colin
 */
public class ResourceImplTest {
    

    @Test
    public void newResource() {
        Resource r = new MockResourceImpl();
        MessageImpl m = new MessageImpl("foo", 1);
        r.markComplete(m);
        assertTrue("Message should have been marked completed", m.isCompleted());
    }

    @Test
    public void testProcessMessageMocked() {
        MockResourceImpl r = new MockResourceImpl();
        MessageImpl m = new MessageImpl("hello", 1);
        r.processMessage(m);
        assertTrue("Message should have been marked completed", m.isCompleted());
    }
    
    @Test(expected=IllegalStateException.class)
    public void testDoubleReceive() {
        MockResourceImpl r = new MockResourceImpl();
        MessageImpl m1 = new MessageImpl("hello", 1);
        MessageImpl m2 = new MessageImpl("goodbye", 2);
        r.receive(m1);
        r.receive(m2);
        fail("Receiving a 2nd message when the 1st one was not yet processed should have thrown an exception");
    }
    
    @Test
    public void testMarkedBusy() {
        MockResourceImpl r = new MockResourceImpl();
        MessageImpl m = new MessageImpl("foo", 1);
        assertTrue("Brand new Resource should be available", r.isAvailable());
        r.receive(m);
        assertFalse("Resource received a Message so should now be busy", r.isAvailable());
        r.processMessage(m);
        assertTrue("Resource has processed the Message so should now be available", r.isAvailable());
    }
    
}
