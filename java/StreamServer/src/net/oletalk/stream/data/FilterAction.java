/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.data;

import java.util.Collection;
import java.util.Set;
import java.util.TreeSet;

/**
 *
 * @author colin
 */
public class FilterAction {
    public enum Action { ALLOW, DENY, BLOCK };
    public enum Option { DOWNSAMPLE, NO_DOWNSAMPLE };

    private String ipBlock;
    private Action action;
    private Set<Option> options;
    
    public FilterAction (String ipBlock, Action action, Collection<Option> options)
    {
        this.ipBlock = ipBlock;
        this.action = action;
        this.options = new TreeSet<>();
        this.options.addAll(options);
    }
    
    public FilterAction (String ipBlock, String action, Collection<String> options)
    {
        this.ipBlock = ipBlock;
        this.action = actionFor(action);
        this.options = new TreeSet<>();
        for (String i : options)
        {
            this.options.add(optionFor(i));
        }
    }
    
    public String getIpBlock()
    {
        return ipBlock;
    }
    
    public Set<Option> getOptions()
    {
        return options;
    }
    
    public Action getAction()
    {
        return action;
    }
    
    public static Action actionFor(String action)
    {
        switch (action)
        {
            case "ALLOW" :
                return Action.ALLOW;
            case "DENY" :
                return Action.DENY;
            case "BLOCK" :
                return Action.BLOCK;
            default :
                throw new IllegalArgumentException ("No action named '" + action + "' exists");
        }
    }
    
    public static Option optionFor(String option)
    {
        switch (option)
        {
            case "DOWNSAMPLE" :
                return Option.DOWNSAMPLE;
            case "NO_DOWNSAMPLE" :
                return Option.NO_DOWNSAMPLE;
            default :
                throw new IllegalArgumentException ("No option matching '" + option + "' exists");
        }   
                
                
    }
    
    public void addOption(Option option)
    {
        // Careful of mutually exclusive options
        if (option == Option.DOWNSAMPLE && options.contains(Option.NO_DOWNSAMPLE))
        {
            options.remove(Option.NO_DOWNSAMPLE);
        }
        else if (option == Option.NO_DOWNSAMPLE && options.contains(Option.DOWNSAMPLE))
        {
            options.remove(Option.DOWNSAMPLE);
        }
        options.add(option);
    }
    
    @Override
    public String toString()
    {
        StringBuilder sb = new StringBuilder();
        sb.append("IP Range: ").append(ipBlock).append(" => ");
        sb.append("Action: ").append(action).append(" ");
        if (options.size() > 0) {
            sb.append("[");
            for (Option o : options)
            {
                sb.append(o);
            }
            sb.append("]");
        }
        return sb.toString();
    }
}
