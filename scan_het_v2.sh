#!/usr/bin/env bash

if [ -z "$1" ] || [ -z "$2" ] || [-z "$3"]; then
    echo -e "\nI need a window length, a step size and an input vcf file to work: '$0 <window_length> <step_size> <vcf_file>'!\n"
    exit 1
fi

while read chrom;do
    counter=0;
    chunkjob=0;
    basename=$(echo $3 | cut -d '.' -f1);
    echo "Writing commands for $chrom";
    while read pregion;do
	read c2 start end <<< $(echo $pregion);
	midpoint=$(printf $start"\t"$end | awk '{print $1+(($2-$1)/2)}');
	region=$(echo $pregion | awk '{print $1":"$2"-"$3}');
	if [ $counter -eq 50 ];then
	    chunkjob=$(echo $chunkjob"+1" | bc);
	    counter=0;
	    printf "" > qu2/$basename.$chrom.$chunkjob.cmds.sh;
	    echo "$chunkjob ...";
	fi;
	echo "tabix -h $3 $region | python het.py --c $chrom --pos $midpoint --f DP:5,120-MQ0:0,1-Q:30,300000-MQ:20,10000" >> qu2/$basename.$chrom.$chunkjob.cmds.sh;
	counter=$(echo $counter"+1" | bc);
    done < <(bedtools makewindows -b BEDs/$chrom.bed -w $1 -s $2);
done < chroms;
