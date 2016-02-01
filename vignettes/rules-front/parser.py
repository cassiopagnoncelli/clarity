import argparse
import sys
import os
import string
import json
import re
from collections import OrderedDict

# Error handling.
def error(msg):
    print json.dumps({ 'error': 1, 'message': msg }, indent=4)
    sys.exit()

# Business Rules class.
class BusinessRules(object):
    def __init__(self, fp):
        self.rules = OrderedDict([('error', 0)])
        self.read_file(fp)
    def read_file(self, fp):
        if not os.path.isfile(fp):
            error("The file does not exists. Did you pass along a file containing rules?")
        with open(fp) as f:
            self.lines = f.readlines()
    def translate_rules(self, s):
        tr = { r" and ": ' & ', r" or ": ' | ' }
        for a, b in tr.items():
            s = re.sub(a, b, s)
        return s
    def parse_rules(self):
        # Convert lines into one single string with whitespaces stripped away.
        str = (' '.join(map(lambda x: x.rstrip(), self.lines))).translate(string.maketrans("\n\t\r", "   "))
        # Translate grammar elements into R syntax (eg. 'and' into &&, 'or' into ||, etc).
        str = self.translate_rules(str)
        # Break the string into ones separated by semi-comma.
        str_rules = map(lambda x: x.strip(), str.split(';'))
        # Create rules of the form
        #
        #   string : integer
        #
        # asserting each string contains exactly one colon in between a
        # left-side hand rule and a right-hand side integer.
        for s in str_rules:
            r = map(lambda x: x.strip(), s.split(':'))
            if len(r) != 2:
                error("Malformed rule: " + s)
            if not unicode(r[1]).isnumeric():
                error("Malformed right-hand side (should be integer): " + s)
            self.rules[r[0]] = int(r[1])
    def to_json(self):
        print json.dumps(self.rules, sort_keys=False, indent=4)

# Command line option '--file' indicates where the input file is located.
def cmdline_arg():
    # argparse rules.
    parser = argparse.ArgumentParser(description="Parse and validate a set of business rules for a data science model.")
    parser.add_argument('-f', '--file', required='True', default='rules.txt')
    # Validates and return.
    file_path = parser.parse_args(sys.argv[1 : ]).file
    return file_path

# Whenever executing as a single application rather than being included as a
# library, pass along the file pointed in the command line options.
if __name__ == '__main__':
    br = BusinessRules(cmdline_arg())
    br.parse_rules()
    br.to_json()
