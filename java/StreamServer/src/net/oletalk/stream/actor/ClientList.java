package net.oletalk.stream.actor;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.InetAddress;
import java.util.HashMap;
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
    
    public Action defaultAction;
    private HashMap<String,FilterAction> filterActions;
    
    
    @PostConstruct
    public void initList(@Value("${clientFilterList}") String filterListPath)
    {
        if (filterListPath != null) 
        {
            readIntoList(filterListPath);
        } else {
            
        }
    }
    
    private void readIntoList(String filterListPath) {
        filterActions = new HashMap<>();
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

                    FilterAction fac = new FilterAction(action, lineitems);  
                    filterActions.put(ipblock, fac);
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
        for (String subnet : filterActions.keySet())
        {
            sb.append(subnet).append(" => ").append(filterActions.get(subnet).toString()).append("\n");
        }
        return sb.toString();
    }
    
    // method to check an incoming ip address against the list
    public Action actionFor(InetAddress addr)
    {
        // test
        String subnet = "192.168.1.0/24";
        SubnetUtils utils = new SubnetUtils(subnet);
        if (utils.getInfo().isInRange(addr.getHostAddress()))
        {
            return Action.ALLOW;
        }
        else {
            return Action.DENY;
        }
    }
    
    public static void main(String[] args) throws Exception {
        ClientList cl = new ClientList();
        cl.initList("clientlist.txt");
        System.out.println("LIST CONTENTS: \n" + cl.toString());
        System.out.println("--DONE--");
        
        //System.out.println(Util.getLineItems("192.168.0.0/24 ALLOW,NO_DOWNSAMPLE", "(\\d+.\\d+.\\d+.\\d/\\d+)\\s+(\\w+)(?:\\s?,(\\w+))*"));
    }
}
