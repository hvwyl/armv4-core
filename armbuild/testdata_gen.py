#!/usr/bin/env python
# -*- coding: UTF-8 -*-

################################
# Test data generator          #
################################

import sys
import os
import getopt
import struct

helpstr = "Usage: {} -i <binstream> -o <testdata>".format(os.path.basename(__file__))
ifile, ofile = "", ""
try:
    opts, _ = getopt.getopt(sys.argv[1:], "i:o:")
except getopt.GetoptError:
    print(helpstr)
    sys.exit()
for (opt, arg) in opts:
    if opt == '-h':
        print(helpstr)
        sys.exit()
    elif opt == "-i":
        ifile = arg
    elif opt == "-o":
        ofile = arg

testdata = ""
with open(ifile, "rb") as f:
    while read := f.read(1):
        instruction = struct.unpack("B", read)[0]
        testdata += "data=0x{:02X}\n".format(instruction)
    f.close()

with open(ofile, "w") as f:
    f.write(testdata)
    f.close()
    