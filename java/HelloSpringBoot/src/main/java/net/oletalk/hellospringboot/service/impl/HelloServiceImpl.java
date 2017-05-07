/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.hellospringboot.service.impl;

import net.oletalk.hellospringboot.service.HelloService;
import org.springframework.stereotype.Service;

/**
 *
 * @author colin
 */
@Service
public class HelloServiceImpl implements HelloService {
    
    
    @Override
    public String getGreeting(String person) {
        return "Hello " + person; // for now
    }


}
