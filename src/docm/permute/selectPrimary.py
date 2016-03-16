#!/usr/bin/python

import csv
import sys

originalfile = sys.argv[1]
permutedfile = sys.argv[2]
outputfile = sys.argv[3]

records = {}
with open(originalfile) as test5:
  reader = csv.reader(test5, delimiter="\t")
  reader.next() 							#getting rid of the header row
  for line in reader:
    readerkey = line[0] + ":" + line[1] + ":" + line[2] + ":" +  line[3] + ":" + line[4]
    records[readerkey] = 1
test5.close()
print len(records)

fileout = open(outputfile,'w')	
with open(permutedfile) as test5:
  reader = csv.reader(test5, delimiter="\t")
  reader.next() #getting rid of the header row
  for line in reader:
    is_primary = 0
    readerkey = line[0] + ":" + line[1] + ":" + line[2] + ":" +  line[3] + ":" + line[4]
    if(readerkey in records):
      is_primary = 1
    fileout.write("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" % (line[0], line[1], line[2], line[3], line[4], line[5], line[6], line[7], line[8], line[9], line[10], line[11], line[12], is_primary))	#write keys of value equal to 1, with key consisting of all mutation details and value reflecting "primary-ness", into a new file
test5.close()
fileout.close()
