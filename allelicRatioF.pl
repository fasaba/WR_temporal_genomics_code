############################################################################
# Check allelic balance: 0.8-0.2
# code by Jazmín Ramos-Madrigal
#
#1       3661    .       T       C       139.77  PASS    AC=1;AF=0.500;AN=2;BaseQRankSum=0.667;ClippingRankSum=0.424;DP=16;FS=0.000;MLEAC=1;MLEAF=0.500;MQ=37.00;MQRankSum=-3.030e-01;QD=8.74;ReadPosRankSum=-1.820e-01;SOR=1.179        GT:AD:DP:GQ:PGT:PID:PL	0/1:12,4:16:99:0|1:3653_C_T:168,0,557
#1       35931141        .       T       A,G     639.77  PASS    AC=1,1;AF=0.500,0.500;AN=2;DP=19;FS=0.000;MLEAC=1,1;MLEAF=0.500,0.500;MQ=37.00;QD=33.67;SOR=1.981       GT:AD:DP:GQ:PL	1/2:0,10,9:19:99:668,310,279,356,0,329

#

use Getopt::Long;

my %opts=();
GetOptions (\%opts,'i=s', 'o=s');

open(IN, $opts{i});
open(OUT, ">$opts{o}");

while(<IN>){
#	$PASS=1;
	if($_ =~ /#/){
		print OUT $_;
		next;
	}
	$line=$_;
	chomp($line);
	@l=split(/\t/, $line);
	$ugt=$l[9];
	@gtline=split(/:/, $ugt);
	$ugt=$gtline[0];

	#If site is missing, or failed in any of the qual filters
	if(($l[3] eq "N") || ($ugt eq "./.") || ($l[6] =~ /FAIL/)){
		#print "$_\n";
		next;
	}

	if(($_ =~ /0\/0/) || ($_ =~ /1\/1/)){
		print OUT $_;
		next;
	}

	@flt=split(/:/, $l[9]);
	if($_ =~ /0\/1/){
		@alleles=split(/,/, $flt[1]);
		$total=$alleles[0]+$alleles[1];
		$diff1=$alleles[0]/$total;
		$diff2=$alleles[1]/$total;
		if((($alleles[0]>$alleles[1]) & ($diff1<0.8) & ($diff2>0.2)) || (($alleles[0]<$alleles[1]) & ($diff2<0.8) & ($diff1>0.2)) || ($alleles[0]==$alleles[1])){
			print OUT $_;
		}
	}elsif($_ =~ /1\/2/){
		@alleles=split(/,/, $flt[1]);
		$total=$alleles[1]+$alleles[2];
		$diff1=$alleles[1]/$total;
		$diff2=$alleles[2]/$total;
		if((($alleles[1]>$alleles[2]) & ($diff1<0.8) & ($diff2>0.2)) || (($alleles[1]<$alleles[2]) & ($diff2<0.8) & ($diff1>0.2)) || ($alleles[1]==$alleles[2])){
			print OUT $_;
		}		
	}
}

close(IN);
close(OUT);

