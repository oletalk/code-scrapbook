/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.hellospringboot.service;

import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import net.oletalk.hellospringboot.exception.S3Exception;

/**
 *
 * @author colin
 */
public interface S3Service {
        public void writeDocument(String objectKey, OutputStream out) throws S3Exception, IOException;
        
        public String uploadDocument(String objectKey, File file);
}
