/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.mp3s.controller;

import java.util.Map;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import net.oletalk.mp3s.dao.TagDAO;
import net.oletalk.mp3s.data.TagInfo;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

/**
 *
 * @author colin
 */

public class TagsController implements org.springframework.web.servlet.mvc.Controller {
    
    private TagDAO dao;
    public void setTagDao(TagDAO t) {
        dao = t;
    }
    
    public ModelAndView handleRequest(HttpServletRequest arg0, HttpServletResponse arg1) {
        ModelAndView view = new ModelAndView();
        view.setViewName("list");
        view.addObject("tags", dao.getEmptyTags());
        
        return view;
    }
}
