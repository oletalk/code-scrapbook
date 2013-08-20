/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.base;

import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;

/**
 * Base class for workaround for having a lot of this app NOT under Spring control.
 * Anything that's a "top level" bean should subclass this...
 * 
 * @author colin
 */
public abstract class SpringBean implements ApplicationContextAware {

    protected static ApplicationContext appCtx;
    
    public static Object getBean (Class cl)
    {
        return appCtx.getBean(cl);
    }

    
    @Override
    public void setApplicationContext(ApplicationContext ac) throws BeansException {
        appCtx = ac;
    }
    
}
