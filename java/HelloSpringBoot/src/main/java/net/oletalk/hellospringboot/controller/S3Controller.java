/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.hellospringboot.controller;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.logging.Level;
import javax.servlet.http.HttpServletResponse;
import net.oletalk.hellospringboot.exception.S3Exception;
import net.oletalk.hellospringboot.service.S3Service;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/**
 *
 * @author colin
 */
@Controller
@RequestMapping("/s3")
public class S3Controller {
    
    @Autowired
    S3Service service;
    
    private static final Logger LOG = Logger.getLogger(HelloController.class);

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
        } catch (S3Exception ex) {
            LOG.error(ex);
        }
    }
    

}
