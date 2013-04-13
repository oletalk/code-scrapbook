/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.mp3s.controller;

import java.util.HashMap;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import net.oletalk.mp3s.dao.TagDAO;
import net.oletalk.mp3s.data.TagInfo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

/**
 *
 * @author colin
 */
@Controller
@RequestMapping("tags/")
public class TagsController {
    
    private TagDAO dao;
    
    @Autowired
    public void setTagDao(TagDAO t) {
        dao = t;
    }
    
    @RequestMapping("update")
    public ModelAndView updateTag(
            @RequestParam(value="hash", required=true) String songHash,
            @RequestParam(value="artist", required=false) String artist,
            @RequestParam(value="title", required=false) String title) {
        
        Map<String,String> newvalues = new HashMap<String,String>();
        newvalues.put("artist", artist);
        newvalues.put("title", title);

        dao.updateTag(songHash, newvalues);
        return listEmptyTags();
    }
    
    @RequestMapping("list")
    public ModelAndView listEmptyTags() {
        ModelAndView view = new ModelAndView();
        view.setViewName("list");
        view.addObject("tags", dao.getEmptyTags());
        
        return view;
    }
}
