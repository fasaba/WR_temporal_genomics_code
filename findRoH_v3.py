import fileinput
from optparse import OptionParser
import sys
import random
import copy 

# Options
usage = "usage: %prog [options] arg1 arg2"
parser = OptionParser(usage=usage)
parser.add_option("-t", action="store", type="float",dest="threshold",help="threshold heterozygosity")
parser.add_option("-f", action="store", type="str",dest="file",help="input file")
parser.add_option("-o", action="store", type="str",dest="output",help="output file")
(options, args) = parser.parse_args()


# load required packages
import numpy as np

### open data file with het values for each window (rows) and for each sample (columns) 
FILE=open(options.file,'r')

# turn data into a list of rows 
DATA=[]
for line in FILE:
	line=line.strip().split()
	DATA.append(line)

# separate header
LABEL=DATA[0]

### slice relevant columns (skip the first 3 because they contain extra info, no het values)
DATA=DATA[1:]
#print(len(DATA[0]))
NEW_DATA=[]
for x in DATA:
	NEW_DATA.append(x[3:])

#print(len(NEW_DATA[0]))


### shape the structure of the output of the count of het windows below a given threshold
OUTPUT=[[] for x in NEW_DATA]
for x in range(0,len(NEW_DATA)):
	for y in range(0,len(NEW_DATA[x])):
		VALUE=float(NEW_DATA[x][y])
		if VALUE<=options.threshold:
			OUTPUT[x].append(1)
		else:
			OUTPUT[x].append(0)

#print(len(OUTPUT[0])) #same structure as input: rows will be windows samples will be columns
OUTPUTFILE=open(options.output,'w')
FORPLOT=[]
MAX=[]


### count number of windows below threshold 
for COL in range(0,len(OUTPUT[0])):
	SAMPLE=[int(x[COL]) for x in OUTPUT]
	PREV=0
	COUNTER=0
	SEQ=[]
	for looker in SAMPLE:
		if PREV==1 and looker==1:  # if we see a 1 and previous instance was 1 too, then sum +1 to the counter of low het windows
			COUNTER+=1
		if PREV==1 and looker==0: # if we see a 0 and previous instance was 1, then stop the counter, adding 1 to account for first low het window
			SEQ.append(COUNTER+1)
			MAX.append(COUNTER+1)
			COUNTER=0

		PREV=looker  # re-set the prev value at the end of each iteration so we keep track of the nature of the previous instance

### prepare output for plotting
	FORPLOT.append(SEQ)

#print(FORPLOT)
# the number of instances in the list of the counters is the number of RoHs
MAX=max(MAX)

# find max number of RoHs identified across samples
MAXROH=[]
for x in FORPLOT:
	MAXROH.append(len(x))
MAXROH=max(MAXROH)

# use that number to set header for output (one column per RoH up until the max number of RoH found)
for x in range(0,MAXROH):
	OUTPUTFILE.write('RoH\t')
OUTPUTFILE.write('\n')

# joing the lists of RoH together in an output file 
for x in FORPLOT:
	OUTPUTFILE.write('\t'.join([str(Z) for Z in x]))
	OUTPUTFILE.write('\n')

# the structure of the final output is samples (rows) by RoH (columns)
# when you open it in R for plotting remember to 'fill' the blanks with NAs
