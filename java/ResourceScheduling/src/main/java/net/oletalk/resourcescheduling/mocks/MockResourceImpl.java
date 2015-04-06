/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.resourcescheduling.mocks;

import java.util.Random;
import net.oletalk.resourcescheduling.impl.Resource;
import net.oletalk.resourcescheduling.interfaces.Message;

/**
 *
 * @author colin
 */
public class MockResourceImpl extends Resource {
    public void processMessage(Message m) {
        Random rand = new Random();
        
        int secs = rand.nextInt(5);
        try {
            Thread.sleep(secs * 1000);
        } catch (InterruptedException ex) { }
        markComplete(m);
    }
}
