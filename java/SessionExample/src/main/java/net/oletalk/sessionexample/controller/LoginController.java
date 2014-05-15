/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.sessionexample.controller;

import java.util.logging.Level;
import java.util.logging.Logger;
import org.apache.shiro.SecurityUtils;
import org.apache.shiro.authc.IncorrectCredentialsException;
import org.apache.shiro.authc.UnknownAccountException;
import org.apache.shiro.authc.UsernamePasswordToken;
import org.apache.shiro.subject.Subject;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

/**
 *
 * @author colin
 */
@Controller
public class LoginController {
        
    //TODO: outfit with Shiro security management - user already logged in etc.
    // requestmapping shouldn't be '/'
    private static final Logger log = Logger.getLogger(LoginController.class.getSimpleName());

    @RequestMapping(value="/front/*", method = RequestMethod.POST)
    @ResponseBody
    public ModelAndView handleRequest(
            @RequestParam(value="username") String username,
            @RequestParam(value="password") String password
            ) {
        
        log.info("Trying to login with given info");
        UsernamePasswordToken token = new UsernamePasswordToken(username, password);
        
        Subject currentUser = SecurityUtils.getSubject();
        
        boolean loginSuccess = false;
        try {
            currentUser.login(token);
            loginSuccess = true;
        } catch ( UnknownAccountException uae ) {
            log.log(Level.INFO, "Unknown account ''{0}''", username);
        } catch ( IncorrectCredentialsException ice ) {
            log.log(Level.INFO, "Incorrect credentials for ''{0}''", username);
        } catch ( Exception e) {
            log.log(Level.SEVERE, "Problems logging in user '" + username + "'", e);
        }
        
        
        
        if (loginSuccess) {
            String userName = currentUser.getPrincipal().toString();
            ModelAndView mav = new ModelAndView("home.jsp");
            log.log(Level.INFO, "Shiro says we have a user! The value is {0}", userName);
            mav.addObject("user", userName);
            return mav;

        }
        log.info("No user info set, redirecting to login page");
        ModelAndView failedLogin = new ModelAndView("/login.jsp");
        failedLogin.addObject("errorMsg", "Your user info was not recognised.");
        return failedLogin;
    }
}

/*
 * To get this (and annotation-based config via WebappInitializer) to work instead of web.xml being used, 
 * you need to have
 * (1) Servlet API v3.0 and above
 * (2) The Eclipse version of the Maven Jetty plugin (jetty-maven-plugin, not maven-jetty-plugin)
 * (3) A 'jetty:run' Maven goal in the 'Actions' section in your Project properties.
 * 
 * Upon Run -> Run you should see something like this in your logs:
 * INFO: JSR-330 'javax.inject.Inject' annotation found and supported for autowiring
 * Apr 05, 2014 2:06:24 PM org.springframework.web.servlet.handler.AbstractHandlerMethodMapping registerHandlerMethod
 * INFO: Mapped "{[/],methods=[GET],params=[],headers=[],consumes=[],produces=[],custom=[]}" 
 *         onto public java.lang.String net.oletalk.sessionexample.controller.LoginController.showIndex()
 * Apr 05, 2014 2:06:25 PM org.springframework.web.context.ContextLoader initWebApplicationContext
 * 
 */