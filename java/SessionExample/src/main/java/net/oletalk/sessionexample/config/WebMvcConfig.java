/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.sessionexample.config;

import java.util.HashMap;
import java.util.Map;
import org.apache.shiro.spring.web.ShiroFilterFactoryBean;
import org.apache.shiro.web.mgt.WebSecurityManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.ViewResolver;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurerAdapter;
import org.springframework.web.servlet.view.InternalResourceViewResolver;
import org.springframework.web.servlet.view.JstlView;

/**
 *
 * @author colin
 */
@EnableWebMvc
@Configuration
@ComponentScan(basePackages = "net.oletalk.sessionexample.controller")
public class WebMvcConfig extends WebMvcConfigurerAdapter {
    
    @Autowired
    private WebSecurityManager securityManager;
    
    // view resolver for HTML files in the project
    @Bean
    public ViewResolver viewResolver() {
        InternalResourceViewResolver viewResolver = new InternalResourceViewResolver();
        viewResolver.setViewClass(JstlView.class);
        //viewResolver.setPrefix("/WEB-INF/");
        //viewResolver.setSuffix(".jsp");
        return viewResolver;
    }
    

    
    // also need to say where the resources are coming from within the project...
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/resources/**").addResourceLocations("/WEB-INF/").setCachePeriod(31556926);
    }

    @Bean
    public ShiroFilterFactoryBean shiroFilter() {
        ShiroFilterFactoryBean shiroFilter = new ShiroFilterFactoryBean();
        shiroFilter.setSecurityManager(securityManager);
        Map<String,String> filterDefs = new HashMap<String,String>();
        filterDefs.put("/members/**", "authc");
        shiroFilter.setFilterChainDefinitionMap(filterDefs);
        shiroFilter.setUnauthorizedUrl("/login.jsp");
        return shiroFilter;
    }

}
