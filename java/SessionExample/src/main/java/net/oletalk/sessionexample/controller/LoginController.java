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
    
    // TEST TEST TEST
    private final String testUserId = "pankaj";
    private final String testPassword = "journaldev";
    // END TEST
    private static final Logger log = Logger.getLogger(LoginController.class.getSimpleName());
    
    @RequestMapping(value="/srv/dologin", method = RequestMethod.POST)
    @ResponseBody
    public ModelAndView handleRequest(
            @RequestParam(value="user") String user,
            @RequestParam(value="pwd") String password,
            HttpServletRequest request,
            HttpServletResponse response
            ) {
        if (this.testUserId.equals(user) && this.testPassword.equals(password)) {
            Cookie loginCookie = new Cookie("user", user);
            loginCookie.setSecure(false);
            loginCookie.setPath("/");
            loginCookie.setMaxAge(45); // 45 seconds - rubbish for actual usage, but nice for debugging
            response.addCookie(loginCookie);
            log.log(Level.INFO, "Set new cookie for user {0}", user);
            ModelAndView mav = new ModelAndView("redirect:/front");
            // 06-04-2014 took me a longggg time to figure out why this was giving me 405 POST not supported errors
            // It looks like switching from home.html to home.jsp did the trick
            // And redirect:/front seems to carry over the cookie ok
            return mav;
        }
        log.info("Login failure - redirecting to login page");
        ModelAndView mav = new ModelAndView("login");
        mav.addObject("errorMsg", "Your user info was not recognised.");
        return mav;
    }
    
}
