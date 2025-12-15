import re
import ipaddress

NFTABLES_ELEMENT_LIST_RE = re.compile(r"elements\s+=\s+{(\s+[^}]+)}", re.MULTILINE)
def getrules(f) -> (dict, dict):
    """
    Returns two maps from reading nftables.conf:
    1. A dict of ip addresses, including those expanded from /24 CIDRs. These are all of the ip address 'elements' in the blacklist.
    2. A dict of ip addresses and the CIDRs they belong to. These are ONLY for the CIDR 'elements' to map blocked IPs to the CIDRs we saw in the blacklist.
    """
    rules = {} # list of ips and *expanded* CIDRs
    cidrs = {} # original list of ips and CIDRs
    lines = ''.join(f.readlines())

    x = re.search(NFTABLES_ELEMENT_LIST_RE, lines)
    if x is not None:
        k = x.group(1)
        for st in k.split(','):
            ip = st.strip()
            # print('KEY: ', st.strip())
            if ip.endswith("/24"):
                print('CIDR: ', ip)
                addrs = ipaddress.ip_network(ip)
                for eachip in addrs:
                    rules[format(eachip)] = 0
                    cidrs[format(eachip)] = ip
            else:
                rules[ip] = 0
    return rules, cidrs

def get_unused_cidrs(cidrmap, all_rules) -> dict:
    # compile list of USED IPs and CIDRs
    ##used_rules = {}
    all_ips = set()
    used_ips = set()
    used_cidrs = set()

    for ip in all_rules.keys():
        if all_rules[ip] > 0:
            if ip in cidrmap: # it's contained in a CIDR rule
                cidr = cidrmap[ip]
                #print(" ip ", ip, " is in CIDR ", cidr)
                used_cidrs.add(cidr)
            else:
                used_ips.add(ip)
                all_ips.add(ip)
        else:
            if ip not in cidrmap:
                all_ips.add(ip)

    print("*** UNUSED IP RULES: ", all_ips - used_ips)
    return set(cidrmap.values()) - used_cidrs
            

def iplists(chk, f) -> dict:
    """Returns a dict of ip addresses found (using chk regex) in opened file f"""
    ips = {}
    for line in f:
        x = re.search(chk, line)
        if x is not None:
            k = x.group(1)
            #        print(line, end="")
            if k in ips:
                num = ips[k]
                ips[k] = num + 1
            else:
                ips[k] = 1
    return ips

