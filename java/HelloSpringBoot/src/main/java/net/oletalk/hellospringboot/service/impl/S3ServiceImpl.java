/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.hellospringboot.service.impl;

import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import net.oletalk.hellospringboot.dao.S3Dao;
import net.oletalk.hellospringboot.exception.S3Exception;
import net.oletalk.hellospringboot.service.S3Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 *
 * @author colin
 */
@Service
public class S3ServiceImpl implements S3Service {

    private static final String DEFAULT_BUCKET = "oletalk";
    
    @Autowired
    S3Dao s3dao;

    @Override
    public void writeDocument(String objectKey, OutputStream out) throws S3Exception, IOException {
        s3dao.getObjectData(DEFAULT_BUCKET, objectKey, out);
    }

    @Override
    public String uploadDocument(String objectKey, File file) {
        try {
            s3dao.uploadFile(DEFAULT_BUCKET, objectKey, file);
        } catch (S3Exception e) {
            return e.getMessage();
        }
        return "Success";
    }
    
    

}
