/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.stream.util;

/**
 *
 * Quick 'n' dirty "is this ip in a given subnet?" class.
 * 
 * @author colin
 */
public class SubnetUtil {
    
    int subnet;
    int netmask;
    
    public SubnetUtil(String subnetStr)
    {
        
        String[] subnetdetails = subnetStr.split("/");
        subnet = toint(subnetdetails[0]);
        netmask = netmaskFromCIDR(subnetdetails[1]);

    }
    
    public boolean inSubnet(String addr)
    {
        int ip = toint(addr);   
        return (ip & netmask) == (subnet & netmask);
    }
    
    private int netmaskFromCIDR(String cidr)
    {
        // assume we get the CIDR without the /, so e.g. 192.168.0.0/24, we just get '24'
        int ret = 0;
        int cid = Integer.parseInt(cidr);
        int pwr = 1;
        
        for (int x = 32; x > 0; x--)        
        {
            if (x <= cid)
            {
                ret += pwr;
            }
            pwr <<= 1;
        }
        return ret;
    }
        
    // convert to an int, assuming ipv4 addresses only
    private int toint(String ipaddr)
    {
        int ret = 0;
        String[] ints = ipaddr.split("\\.");
        int pow = 1;
        for (int i = 0; i < 4; i++)
        {
            int v = Integer.parseInt(ints[3-i]);
            ret += v * pow;
            pow *= 256;
            
        }
        return ret;
    }
}
