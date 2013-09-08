package net.oletalk.stream.actor;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.annotation.PostConstruct;
import net.oletalk.stream.data.FilterAction;
import net.oletalk.stream.util.LogSetup;
import net.oletalk.stream.util.Util;
import org.apache.commons.net.util.SubnetUtils;
import org.springframework.beans.factory.annotation.Value;
import static net.oletalk.stream.data.FilterAction.Action;

/**
 * ClientList - whitelist/blacklist for incoming ips by subnet
 * @author colin
 */
public class ClientList {

    
    private static final String CLIENT_FILE_FORMAT = "(\\d+.\\d+.\\d+.\\d/\\d+)\\s+(\\w+)(?:\\s?,(\\w+))*";
    
    private static final Logger LOG = LogSetup.getlog();
    
    @Value("${defaultAction}")
    private Action defaultAction;
    
    @Value("${clientFilterList}")
    private String filterListPath;

    private List<FilterAction> filterActions;

    @PostConstruct
    public void initList() throws Exception
    {
        if (filterListPath != null) 
        {
            readIntoList(filterListPath);
        } else {
            throw new Exception("Filter List path was not set");
        }
    }
    
    public void initList(String flistpath) throws Exception
    {
        setFilterListPath(flistpath);
        initList();
    }
    
    public void setDefaultAction(String action)
    {
        defaultAction = Action.valueOf(action);
    }
    
    public Action getDefaultAction()
    {
        return defaultAction;
    }
    
    public void setFilterListPath(String filterListPath)
    {
        this.filterListPath = filterListPath;
    }
    
    
    private void readIntoList(String filterListPath) {
        filterActions = new ArrayList<>();
        BufferedReader br = new BufferedReader(
                                new InputStreamReader(
                                    ClassLoader.getSystemResourceAsStream(filterListPath)));
        String dataRow;
        try {
            while ((dataRow = br.readLine()) != null)
            {
                // should be of the format 192.168.0.0/24 ALLOW,NO_DOWNSAMPLE
                List<String> lineitems = Util.getLineItems(dataRow, CLIENT_FILE_FORMAT);
                if (lineitems.size() >= 2)
                {
                    String ipblock = lineitems.remove(0); // TODO: validate subnet?
                    String action = lineitems.remove(0);

                    filterActions.add(new FilterAction(ipblock, action, lineitems));
                }       
            
            }
        } catch (IOException ex) {
            LOG.log(Level.SEVERE, "Problem reading from file into client list", ex);
        }
        
    }

    @Override
    public String toString()
    {
        StringBuilder sb = new StringBuilder();
        for (FilterAction fa : filterActions)
        {
            sb.append(fa.toString()).append("\n");
        }
        return sb.toString();
    }
    
    // method to check an incoming ip address against the list
    public FilterAction filterActionFor(String addr)
    {
        // test
        for (FilterAction fa : filterActions)
        {
            String subnet = fa.getIpBlock();
            SubnetUtils utils = new SubnetUtils(subnet);
            
            if (utils.getInfo().isInRange(addr))
            {
                LOG.log(Level.INFO, "Action for peer {0} is {1}", new Object[]{addr, fa});
                return fa;
            }
            
        }
        return null;
    }
    
    public static void main(String[] args) throws Exception {
        ClientList cl = new ClientList();
        cl.initList("clientlist.txt");
        cl.setDefaultAction("BLOCK");
        List<String> testips = Arrays.asList(new String[]{"192.168.0.4", "211.200.100.160", "194.168.0.11"});
        for (String ip : testips)
        {
            System.out.println(ip + ": " + cl.filterActionFor(ip));
        }
        System.out.println("LIST CONTENTS: \n" + cl.toString());
        System.out.println("--DONE--");
        
    }
}
