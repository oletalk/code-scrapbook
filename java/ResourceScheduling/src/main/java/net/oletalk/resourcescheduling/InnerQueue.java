/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.resourcescheduling;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Set;
import java.util.SortedSet;
import java.util.TreeSet;
import java.util.concurrent.ConcurrentHashMap;
import net.oletalk.resourcescheduling.impl.MessageImpl;

/**
 *
 * @author colin
 */
class InnerQueue {
    private ConcurrentHashMap<Integer,List<MessageImpl>> queue;

    public InnerQueue() {
        queue = new ConcurrentHashMap<Integer,List<MessageImpl>>();
    }
    
    public synchronized void insertMessage(MessageImpl m) {
        Integer gid = new Integer(m.getGroupId());
        List<MessageImpl> list = queue.get(gid);
        if (list == null) {
            list = new ArrayList<MessageImpl>();
        }
        list.add(m);
        queue.put(gid, list);
    }
    
    public Set<Integer> getActiveGroups() {
        return queue.keySet();
    }
    
    public MessageImpl getMessageFromGroups(Integer... groups) {        
        for (Integer gid : groups) {
            if (queue.contains(gid)) {
                return getMessageFromGroup(gid);
            }
        }
        return null;
        
    }
    
    
    public MessageImpl getMessage() {
        Set<Integer> groupids = queue.keySet();
        if (!groupids.isEmpty()) {
            Integer id = groupids.iterator().next();
            return getMessageFromGroup(id);
        }
        return null;
    }
    
    
        // return a message from a given group
    // PRECONDITION: the group is not empty
    private MessageImpl getMessageFromGroup(Integer id) {
        List<MessageImpl> list = queue.get(id);
        if (!list.isEmpty()) {
            MessageImpl m = list.remove(0);
            if (list.isEmpty()) {
                queue.remove(id);
            }
            return m;
        }
        return null;
    }

}
