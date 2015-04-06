/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.resourcescheduling.impl;

import java.util.ArrayList;
import java.util.List;
import net.oletalk.resourcescheduling.interfaces.Gateway;
import net.oletalk.resourcescheduling.interfaces.Message;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 *
 * @author colin
 */
public class GatewayImpl implements Gateway {
    private Logger log = LoggerFactory.getLogger(GatewayImpl.class);

    private List<Resource> resources;
    
    public void addResource(Resource r) {
        if (resources == null) {
            resources = new ArrayList<Resource>();
        }
        resources.add(r);
    }
    
    public void send(Message msg) {
        Resource r = firstResourceAvailable();
        if (r != null) {
            r.receive(msg);
            log.info("Sent message on to available resource.");
        } else {
            throw new IllegalStateException("No resources available");
        }
    }
    
    public boolean anyResourcesAvailable() {
        return (firstResourceAvailable() != null);
    }
    
    Resource firstResourceAvailable() {
        for (Resource r : resources) {
           if (r.isAvailable()) {
               return r;
           }
        }
        return null;
    }
}
