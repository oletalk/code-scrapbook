/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.hellospringboot.service.impl;

import java.io.IOException;
import java.io.OutputStream;
import net.oletalk.hellospringboot.dao.S3Dao;
import net.oletalk.hellospringboot.service.HelloService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 *
 * @author colin
 */
@Service
public class HelloServiceImpl implements HelloService {
    
    private static final String DEFAULT_BUCKET = "oletalk";
    
    @Autowired
    S3Dao s3dao;
    
    @Override
    public String getGreeting(String person) {
        return "Hello " + person; // for now
    }

    @Override
    public void writeDocument(String objectKey, OutputStream out) throws IOException {
        s3dao.getObjectData(DEFAULT_BUCKET, objectKey, out);
    }

}
