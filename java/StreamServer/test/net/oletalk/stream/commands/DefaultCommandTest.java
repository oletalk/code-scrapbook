/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.commands;

import com.sun.net.httpserver.Headers;
import com.sun.net.httpserver.HttpExchange;
import java.io.OutputStream;
import java.io.PrintStream;
import java.util.Map;
import net.oletalk.stream.util.TesterOutputStream;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

/**
 *
 * @author colin
 */
public class DefaultCommandTest {
    
    public DefaultCommandTest() {
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
     * Test of exec method, of class DefaultCommand.
     */
    @Test
    public void testExec() throws Exception {
        System.out.println("exec");
        Map<String, Object> args = null;
        
        // We need a mock HttpExchange for the defaultcommand instance
        Headers headers = mock(Headers.class);
        
        HttpExchange exchange = mock(HttpExchange.class);
        
        when(exchange.getResponseHeaders()).thenReturn(headers);
        TesterOutputStream tos = new TesterOutputStream();
        when(exchange.getResponseBody()).thenReturn(tos.getOutputStream());
        String rootdir = "/home/mp3s";
        
        DefaultCommand instance = new DefaultCommand(exchange, rootdir);
        instance.exec();
        assertEquals("Bad Request", tos.result());
    }
}