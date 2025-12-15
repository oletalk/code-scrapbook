import argparse
import os.path

def get_args():
    """Returns location of journal file and nftables config file as specified in command line arguments"""

# get args
    parser = argparse.ArgumentParser(
            prog="grep_ips", # TODO better name
            description="Determines which nftables blacklist entries were used"
    )
    parser.add_argument('-e', '--extract')
    parser.add_argument('-c', '--config')
    args = parser.parse_args()
    journal_file = args.extract
    config_file = args.config

    if journal_file is not None:
        if not os.path.isfile(journal_file):
            print("Given journal file extract does not exist!")
            exit(1)
    else:
        print("Please provide a journal file extract with -e!")
        exit(1)

    if config_file is not None:
        if (not os.path.isfile(config_file)):
            print("Given nftables configuration file does not exist!")
            exit(2)
    else:
        print("Please provide the location of your nftables.conf with -c!")
        exit(1)
    return journal_file, config_file
