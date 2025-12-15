#!/usr/bin/env python3
import re
import modules.list_manip as l
import modules.argvalidate as a

LOWER_BOUND = 50 
JOURNAL_FILE, NFTABLES_CONFIG_FILE = a.get_args()
#JOURNAL_FILE = args.extract
#NFTABLES_CONFIG_FILE = args.config
#JOURNAL_FILE = "/home/colin/scrap/journal.txt"
#NFTABLES_CONFIG_FILE = "/etc/nftables.conf"
# developed with regex101.com
JOURNAL_NFT_BLOCK_LOG = re.compile(r"DROP.*SRC=(.*?)\s")

f = open(JOURNAL_FILE, "rt", encoding="utf-8")
ips = l.iplists(JOURNAL_NFT_BLOCK_LOG, f)

f = open(NFTABLES_CONFIG_FILE, "rt", encoding="utf-8")
rules, cidrmap = l.getrules(f)

f.close()

print('1. JOURNAL BLOCKED IPS')
hiddencount = 0
for blockedip in sorted(ips.keys(), key=lambda k: ips[k], reverse=True):
    hits = ips[blockedip]
    if hits >= LOWER_BOUND:
        print(f"   {blockedip} --> {hits}")
    else:
        hiddencount += 1
    if blockedip in rules:
        num = rules[blockedip]
        rules[blockedip] = num + 1
if hiddencount > 0:
    print(f"[{hiddencount} hidden hosts below hit threshold]")

# we have rules -- all rules in the blacklist with /24 cidrs expanded.
#                  with a value of how many times that ip was blocked in the nft log

# we have cidrmap -- a map of ips expanded from CIDRs, of the form
#                  ip -> cidr it's from, to help link them back

# which CIDRs had no ips that triggered the blocklist?
unused_cidrs, unused_ips = l.get_unused_rules(cidrmap, rules)
if len(unused_cidrs) > 0:
    print("2. UNUSED CIDR RULES: ", unused_cidrs)
else:
    print("2. -- NO UNUSED CIDR RULES --")

if len(unused_ips) > 0:
    print("3. UNUSED IP RULES: ", unused_ips)
else:
    print("3. -- NO UNUSED IP RULES --")
