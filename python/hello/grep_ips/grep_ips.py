#!/usr/bin/env python3
import re
import modules.list_manip as l

JOURNAL_FILE = "/home/colin/scrap/journal.txt"
NFTABLES_CONFIG_FILE = "/etc/nftables.conf"
# developed with regex101.com
JOURNAL_NFT_BLOCK_LOG = re.compile(r"DROP.*SRC=(.*?)\s")


        
f = open(JOURNAL_FILE, "rt", encoding="utf-8")
ips = l.iplists(JOURNAL_NFT_BLOCK_LOG, f)

f = open(NFTABLES_CONFIG_FILE, "rt", encoding="utf-8")
rules, cidrmap = l.getrules(f)

print('### JOURNAL BLOCKED IPS ###')
for blockedip in sorted(ips.keys(), key=lambda k: ips[k], reverse=True):
    print(blockedip, " --> ", ips[blockedip])
    if blockedip in rules:
        num = rules[blockedip]
        rules[blockedip] = num + 1
f.close()

# we have rules -- all rules in the blacklist with /24 cidrs expanded.
#                  with a value of how many times that ip was blocked in the nft log

# we have cidrmap -- a map of ips expanded from CIDRs, of the form
#                  ip -> cidr it's from, to help link them back

# which CIDRs had no ips that triggered the blocklist?
print("--> UNUSED CIDR RULES: ", l.get_unused_cidrs(cidrmap, rules))
