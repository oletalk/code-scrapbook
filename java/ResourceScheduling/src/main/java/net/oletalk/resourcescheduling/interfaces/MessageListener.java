/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.resourcescheduling.interfaces;

/**
 *
 * A way to notify the scheduler that a message from a certain group has completed processing
 * 
 * @author colin
 */
public interface MessageListener {
    public void completed(int groupId);
}
