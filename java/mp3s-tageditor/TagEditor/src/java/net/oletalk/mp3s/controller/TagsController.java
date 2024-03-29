/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.mp3s.controller;

import java.util.HashMap;
import java.util.Map;
import net.oletalk.mp3s.dao.TagDAO;
import net.oletalk.mp3s.util.ParamUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

/**
 *
 * @author colin
 */
@Controller
@RequestMapping("tags/")
public class TagsController {
    
    @Autowired
    private TagDAO dao;
    
    @RequestMapping("update")
    public ModelAndView updateTag(
            @RequestParam(value="hash", required=true) String songHash,
            @RequestParam(value="artist", required=false) String artist,
            @RequestParam(value="title", required=false) String title) {
        
        Map<String,String> newvalues = new HashMap<String,String>();
        newvalues.put("artist", artist);
        newvalues.put("title", title);

        dao.updateTag(songHash, newvalues);
        return listEmptyTags(null, null);
    }
    
    @RequestMapping("list")
    public ModelAndView listEmptyTags(
            @RequestParam(value="numrows", defaultValue="20", required=false) String numRows,
            @RequestParam(value="offset", defaultValue="0", required=false) String offset) {
        ModelAndView view = new ModelAndView();
        view.setViewName("list");
        int pagesize = ParamUtils.parseOrZero(numRows);
        int pageoffset = ParamUtils.parseOrZero(offset);
        view.addObject("tags", dao.getEmptyTags(pagesize, pageoffset));
        view.addObject("offset", pageoffset);
        view.addObject("numrows", pagesize);
        return view;
    }
}
