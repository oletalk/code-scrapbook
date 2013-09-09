/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.actor;

import net.oletalk.stream.data.FilterAction;
import net.oletalk.stream.data.FilterAction.Action;
import net.oletalk.stream.data.FilterAction.Option;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 *
 * @author colin
 */
public class ClientListTest {
    
    public ClientListTest() {
    }
    
    @BeforeClass
    public static void setUpClass() {
    }
    
    @AfterClass
    public static void tearDownClass() {
    }
    
    @Before
    public void setUp() {
    }
    
    @After
    public void tearDown() {
    }

    /**
     * Test of initList method, of class ClientList.
     */
    @Test
    public void testInitList_0args() throws Exception {
        System.out.println("initList");
        ClientList instance = new ClientList();
        
        instance.setFilterListPath("clientlist-test2bad.txt");
        
        try {
            instance.initList();
            fail("Test should have thrown an exception due to badly-formed clientlist.txt file");
            
        } catch (IllegalArgumentException iae) {
            assert("No action named 'ALL' exists".equals(iae.getMessage()));
        }
    }

    /**
     * Test of initList method, of class ClientList.
     */
    @Test
    public void testInitList_String() throws Exception {
        System.out.println("initList");
        String flistpath = "clientlist-test1.txt";
        ClientList instance = new ClientList();
        instance.initList(flistpath);

        
        assertNotEquals(instance.filterActionFor("192.168.1.4"), null);
        
        FilterAction fa0 = instance.filterActionFor("192.168.0.4");
        assertEquals(fa0.getIpBlock(), "192.168.0.0/24");
        
        FilterAction fa1 = instance.filterActionFor("192.168.3.4");
        assertEquals(fa0.getAction(), Action.ALLOW);
        assert(fa0.getOptions().contains(Option.DOWNSAMPLE));
        assert(fa1.getOptions().contains(Option.NO_DOWNSAMPLE));
        assertEquals(instance.filterActionFor("194.168.0.4"), null);
    }

    /**
     * Test of setDefaultAction method, of class ClientList.
     */
    @Test
    public void testSetDefaultAction() {
        System.out.println("setDefaultAction");
        
        ClientList instance = new ClientList();
        instance.setDefaultAction("ALLOW");
        assertEquals(Action.ALLOW, instance.getDefaultAction());
        
        instance.setDefaultAction("DENY");
        assertEquals(Action.DENY, instance.getDefaultAction());
    }


    /**
     * Test of toString method, of class ClientList.
     */
    @Test
    public void testToString() throws Exception {
        System.out.println("toString");
        ClientList instance = new ClientList();
        String expResult = "Default action: null";
        String result = instance.toString();
        assertEquals(expResult, result);
    }

    /**
     * Test of filterActionFor method, of class ClientList.
     */
    @Test
    public void testFilterActionFor() throws Exception {
        System.out.println("filterActionFor");
        String addr = "";
        ClientList instance = new ClientList();
        String flistpath = "clientlist-test1.txt";
        instance.initList(flistpath);
        
        assertNotEquals(instance.filterActionFor("192.168.1.4"), null);
    }

}