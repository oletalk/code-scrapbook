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
import org.apache.shiro.SecurityUtils;
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
public class LogoutController {
    
    private static final Logger log = Logger.getLogger(LogoutController.class.getSimpleName());
    
    @RequestMapping(value="/logout", method = RequestMethod.POST)
    @ResponseBody
    public ModelAndView handleRequest() {

        String userName = "";
        Subject currentUser = SecurityUtils.getSubject();
        if (currentUser != null) {
            userName = " " + currentUser.getPrincipal().toString();
            currentUser.logout();            
        }
                
        ModelAndView mav = new ModelAndView("login.jsp");
        mav.addObject("errorMsg", "Thank you" + userName + ", please come again.");
        return mav;
    }
    
}
