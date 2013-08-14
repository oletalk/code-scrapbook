/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream;

import java.nio.file.Paths;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import net.oletalk.stream.dao.TagDao;
import net.oletalk.stream.data.Tag;
import net.oletalk.stream.util.LogSetup;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

/**
 *
 * @author colin
 */
public class Scrap {
    
    private static final Logger LOG = LogSetup.getlog();
    
    public static void main(String[] args)
    {
        
        ApplicationContext ctx = new ClassPathXmlApplicationContext("streamserverContext.xml");
        TagDao td = ctx.getBean(TagDao.class);

        Tag t = td.getTag("40af41bb6d0f190c56ab3d9dc5e3acd7");
        System.out.println(t);
    }
}
