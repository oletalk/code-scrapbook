/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.hellospringboot.controller;

import java.io.IOException;
import javax.servlet.http.HttpServletResponse;
import net.oletalk.hellospringboot.service.HelloService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.apache.log4j.Logger;

/**
 *
 * @author colin
 */

@Controller
@RequestMapping("/hello")
public class HelloController {
    
    private static final Logger LOG = Logger.getLogger(HelloController.class);
    
    @Autowired
    HelloService service;
    
    @RequestMapping("/to")
    @ResponseBody
    String home(@RequestParam(value="name", required=false, defaultValue="world") String name) {
        return service.getGreeting(name);
    }
    
    @RequestMapping("/from")
    void from(@RequestParam(value="key") String objectKey, HttpServletResponse response) {
        try {
            service.writeDocument(objectKey, response.getOutputStream());            
        } catch (IOException ioe) {
            try {
                response.getWriter().println("Error in response: " + ioe.toString());            
            } catch (IOException e) {
                LOG.error(e);
            }
        }
    }

}
