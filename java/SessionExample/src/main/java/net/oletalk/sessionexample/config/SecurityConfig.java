/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.sessionexample.config;

import org.apache.shiro.realm.text.IniRealm;
import org.apache.shiro.web.mgt.DefaultWebSecurityManager;
import org.apache.shiro.web.mgt.WebSecurityManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 *
 * @author colin
 */
@Configuration
public class SecurityConfig {
    @Bean
    public WebSecurityManager securityManager() {
        DefaultWebSecurityManager securityManager = new DefaultWebSecurityManager();
        securityManager.setRealm(new IniRealm("classpath:realm.ini"));
        return securityManager;
    }
 
}
