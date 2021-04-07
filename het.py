import fileinput
from optparse import OptionParser
import sys
import random
import copy 

# Options
usage = "usage: %prog [options] arg1 arg2"
parser = OptionParser(usage=usage)
parser.add_option("--pos", action="store", type="int",dest="pos",help="position")
parser.add_option("--chrom", action="store", type="str",dest="chrom",help="chromosome")
parser.add_option("--f", action="store", type="string", dest="filters",help="params to filter individuals")
(options, args) = parser.parse_args()

def safediv(n,d):
    # Dividing by zero is bad
    if d==0:
        return 0
    else:
        return float(n)/d

def filter_genotype(info,genotype,parameters,values):
    # Return the filtered genotype
    for i,p in enumerate(parameters):
        minv,maxv = values[i]
        iparameter = info.split(":").index(p)
        gparameter = genotype.split(":")[iparameter]
        if gparameter == ".":
            return "."
        else:
            if float(gparameter) >= int(maxv) or float(gparameter) < int(minv):
                return "."
    return genotype

def process_filters(paramstring):
    # Returns the thersholds for each param
    params = [x.split(":")[0] for x in paramstring.split("-")]
    values = [map(int,x.split(":")[1].split(",")) for x in paramstring.split("-")]
    return params,values

for line in sys.stdin:
    
    #Read header
    if line.startswith("#"):
        if line.startswith("#CHROM"):
            samples = line.split()[9:]
            het={}
            params,values = process_filters(options.filters)
            for s in samples:
                het[s]=[0,0]
        continue

    fields = line.split()

    #Skip lines with no info in important params
    if any(p not in fields[8].split(":") for p in params):
            continue

    # Digest genotypes
    genotypes=[]
    for x in fields[9:]:
        if "./." not in x and x!=".":
            genotypes.append(filter_genotype(fields[8],x,params,values).split(":")[0])
        else:
            genotypes.append(".")
    
    # Iterate over all individuals
    for i,s in enumerate(samples):
        if genotypes[i] not in ["0/0","0/1","1/1"]:
            continue
        if genotypes[i]=="0/1":
            het[s][0]+=1
        het[s][1]+=1

## Output format is:
## $chromosome  $mid_position  $total_hets_in_window  $total_base-pairs_visited  $heterozygous_positions_per_base-pair  $individual
for s in het:
    print "{}\t{}\t{}\t{}\t{}\t{}".format(options.chrom,options.pos,het[s][0],het[s][1],safediv(het[s][0],het[s][1]),s)
