/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.hellospringboot.dao;

import com.amazonaws.auth.ClasspathPropertiesFileCredentialsProvider;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.AmazonS3Exception;
import com.amazonaws.services.s3.model.GetObjectRequest;
import com.amazonaws.services.s3.model.S3Object;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.Charset;
import org.apache.log4j.Logger;
import org.apache.tomcat.util.http.fileupload.IOUtils;
import org.springframework.stereotype.Repository;

/**
 *
 * @author colin
 */
@Repository
public class S3Dao {
    /*
     * Sample bucket 'oletalk' and key is your filename
    */
    private static final Logger LOG = Logger.getLogger(S3Dao.class);
    
    public void getObjectData(String bucketName, String key, OutputStream out) throws IOException {
        AmazonS3 s3client = new AmazonS3Client(new ClasspathPropertiesFileCredentialsProvider());
        LOG.info("fetching requested object " + key);
        try {
            S3Object object = s3client.getObject(new GetObjectRequest(bucketName, key));
            LOG.info("fetched, serving up");
            IOUtils.copy(object.getObjectContent(), out);
        } catch (AmazonS3Exception e) {
            LOG.error("Problem fetching from S3: ", e);
            String errorMsg = "Error fetching document";
            out.write(errorMsg.getBytes(Charset.defaultCharset()));
        }
    }
}
