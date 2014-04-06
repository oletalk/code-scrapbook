/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.sessionexample.controller;

import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

/**
 *
 * @author colin
 */
@Controller
public class IndexController {
    
    private static final Logger log = Logger.getLogger(IndexController.class.getSimpleName());

    @RequestMapping(value="/front", method = {RequestMethod.GET, RequestMethod.POST})
    @ResponseBody
    public ModelAndView handleRequest(
            @CookieValue(value = "user", required=false) String userCookie,
            HttpServletRequest request, HttpServletResponse response
            ) {
        
        log.info("IndexController.handleRequest called!");
        if (userCookie != null) {
            ModelAndView mav = new ModelAndView("home");
            log.log(Level.INFO, "We have a cookie! The value is {0}", userCookie);
            mav.addObject("user", userCookie);
            return mav;
        } else {
            // debugging info - we were expecting a 'user' cookie, but instead we have...?
            Cookie[] cookies = request.getCookies();
            log.log(Level.INFO, "Checking request for cookies - we have {0}", cookies.length);
            for (Cookie c : cookies) {
                log.log(Level.INFO, "  - one named ''{0}'' with value ''{1}''", new Object[]{c.getName(), c.getValue()});
            }
        }
        log.info("No user info set, redirecting to login page");
        return new ModelAndView("login");
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
 *         onto public java.lang.String net.oletalk.sessionexample.controller.IndexController.showIndex()
 * Apr 05, 2014 2:06:25 PM org.springframework.web.context.ContextLoader initWebApplicationContext
 * 
 */