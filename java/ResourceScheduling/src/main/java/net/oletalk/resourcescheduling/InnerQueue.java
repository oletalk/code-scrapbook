/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.resourcescheduling;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
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
    
    public MessageImpl getMessage() {
        Set<Integer> groupids = queue.keySet();
        if (!groupids.isEmpty()) {
            Integer id = groupids.iterator().next();
            List<MessageImpl> list = queue.get(id);
            if (!list.isEmpty()) {
                return list.remove(0);
            }
        }
        return null;
    }
    
}
