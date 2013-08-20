/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.util;

import net.oletalk.stream.base.SpringBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.core.env.Environment;

/**
 *
 * @author colin
 */

@Configuration
@PropertySource("classpath:config.properties")
public class Config extends SpringBean {
    
    @Autowired
    Environment environment;
    
    public static Config getBean()
    {
        return (Config) SpringBean.getBean(Config.class);
    }
    
    public String get(String prop)
    {
        return environment.getProperty(prop);
    }
    
}
