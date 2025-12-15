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
                    cidrs[eachip] = ip
            else:
                rules[ip] = 0
    return rules, cidrs

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

