/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.sessionexample.init;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletRegistration;
import net.oletalk.sessionexample.config.AppConfig;
import net.oletalk.sessionexample.config.SecurityConfig;
import net.oletalk.sessionexample.config.WebMvcConfig;
import org.springframework.web.WebApplicationInitializer;
import org.springframework.web.context.ContextLoaderListener;
import org.springframework.web.context.support.AnnotationConfigWebApplicationContext;
import org.springframework.web.filter.DelegatingFilterProxy;
import org.springframework.web.servlet.DispatcherServlet;

/**
 *
 * @author colin
 */

public class AppInitializer implements WebApplicationInitializer {
    
    @Override
    public void onStartup(ServletContext container) throws ServletException {
        // set up 'root' spring app context
        AnnotationConfigWebApplicationContext rootContext = new AnnotationConfigWebApplicationContext();
        rootContext.register(AppConfig.class, SecurityConfig.class);
        
        // manage the lifecycle of the root app context
        container.addListener(new ContextLoaderListener(rootContext));
        // set up dispatcher servlet context
        AnnotationConfigWebApplicationContext dispatcherContext = new AnnotationConfigWebApplicationContext();
        dispatcherContext.register(WebMvcConfig.class);
        
        ServletRegistration.Dynamic dispatcher = container.addServlet("dispatcher", new DispatcherServlet(dispatcherContext));
        dispatcher.setLoadOnStartup(1);
        dispatcher.addMapping("/");
        
        
        // --- add the Shiro filter declared in WebMvcConfig ----
        // it doesn't really do anything besides provide use of the Shiro SecurityManager
        container.addFilter("shiroFilter", new DelegatingFilterProxy("shiroFilter", dispatcherContext))
               .addMappingForUrlPatterns(null, false, "/*");
        
    }
}