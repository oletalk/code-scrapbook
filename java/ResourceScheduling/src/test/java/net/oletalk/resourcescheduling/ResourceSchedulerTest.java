/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.resourcescheduling;

import org.junit.Test;
import static org.junit.Assert.*;

/**
 *
 * @author colin
 */
public class ResourceSchedulerTest {

    @Test
    public void testNewScheduler() {
        ResourceScheduler rs = new ResourceScheduler(1);
        assertEquals("Scheduler should have been configured with just one resource available", 1, rs.getNumResources());
    }
    

}
