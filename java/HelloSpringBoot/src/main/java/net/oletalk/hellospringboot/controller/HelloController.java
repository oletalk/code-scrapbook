/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.hellospringboot.controller;

import java.io.File;
import java.io.IOException;
import net.oletalk.hellospringboot.service.HelloService;
import net.oletalk.hellospringboot.service.S3Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.apache.log4j.Logger;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

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
    
    @Autowired
    S3Service s3service;
    
    @RequestMapping("/to")
    @ResponseBody
    String home(@RequestParam(value="name", required=false, defaultValue="world") String name) {
        return service.getGreeting(name);
    }
    
    @GetMapping("/doc/")
    String index() {
        return "hello";
    }
    
    @PostMapping("/upload")
    public String handleFileUpload(@RequestParam("file") MultipartFile file, RedirectAttributes attributes ) {
        // multipart file upload is slightly different
        
        
        String originalName = file.getOriginalFilename();
        // TODO any way of getting files uploaded without transferring to a temp file?
        //  It seems to want to know the complete path but MultipartFile doesn't give us that.
        String returnMsg;
        try {
            LOG.info("Creating temp file for upload");
            File tmpFile = File.createTempFile("s3upload", null);
            tmpFile.deleteOnExit();
            file.transferTo(tmpFile);
            returnMsg = s3service.uploadDocument("test/" + originalName, tmpFile);
            attributes.addFlashAttribute("message", returnMsg);
        } catch (IOException ioe) {
            LOG.error("Error creating temp file for upload:" + ioe.toString());
            attributes.addFlashAttribute("message", "Problem preparing upload to S3");
        }
        return "redirect:/hello/doc/";
    }

}
