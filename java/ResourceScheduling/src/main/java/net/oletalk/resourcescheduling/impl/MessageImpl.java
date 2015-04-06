/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.resourcescheduling.impl;

import java.util.ArrayList;
import java.util.List;
import net.oletalk.resourcescheduling.interfaces.Message;
import net.oletalk.resourcescheduling.interfaces.MessageListener;

/**
 * Default implementation class for a Message based on given requirements.
 * We assume the Message has some content and a group id.
 * @author colin
 */
public class MessageImpl implements Message {
    private String content;
    private int groupId;
    private boolean isComplete = false;
    
    private List<MessageListener> listeners;
    
    
    public MessageImpl(String content_, int groupId_) {
        content = content_;
        groupId = groupId_;
        
        listeners = new ArrayList<MessageListener>();
    }
    
    public void addListener(MessageListener listener_) {
        listeners.add(listener_);
    }
    
    public String getContent() {
        return content;
    }
        
    public int getGroupId() {
        return groupId;
    }
    
    @Override
    public void completed() {
        isComplete = true;
        for (MessageListener l : listeners) {
            l.completed(this.groupId);
        }
    }
    
    public boolean isCompleted() {
        return isComplete;
    }
    
    @Override
    public String toString() {
        return "Message, content = '" + content + "', group id = " + groupId + ", complete = " + isComplete;
    }
}
