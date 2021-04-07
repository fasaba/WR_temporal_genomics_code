## code by Jazmín Ramos-Madrigal

###time java8 -jar /home/jmoreno/data/my_kelvin_data/Scripts/GenomeAnalysisTK-3.4-0/GenomeAnalysisTK.jar -T VariantFiltration -R /home/jmoreno/data/my_kelvin_data/bwa_genomes/HG37.1/hs.build37.1.fa -V Clovis_22_genotypes_raw.vcf --filterExpression "QD < 2.0 || FS > 60.0 || MQ < 30 || MQRankSum < -12.5 || ReadPosRankSum < -8.0 || DP < 10" --filterName "my_snp_filter" -o Clovis_22_genotypes_filtered.vcf &
###QD < 2.0 || FS > 60.0 || MQ < 30 || MQRankSum < -12.5 || ReadPosRankSum < -8.0 || DP < 10
###22      18235305        .       T       C       347.77  .       AC=1;AF=0.500;AN=2;BaseQRankSum=0.675;ClippingRankSum=-1.528e+00;DP=21;FS=10.942;MLEAC=1;MLEAF=0.500;MQ=37.00;MQRankSum=0.320;QD=16.56;ReadPosRankSum=0.675;SOR=2.004      GT:AD:DP:GQ:PGT:PID:PL  0/1:12,9:21:99:0|1:18235288_C_G:376,0,726
use Getopt::Long;

my %opts=();
GetOptions (\%opts,'i=s', 'o=s');

open(IN, $opts{i});
open(OUT, ">$opts{o}");

while(<IN>){
	$PASS=1;
	if($_ =~ /#/){
		print OUT $_;
		next;
	}
	$line=$_;
	chomp($line);
	@l=split(/\t/, $line);
	$flt=$l[6];
	if($_ =~ /QD=(\d+\.?\d*)/){
		if($1 < 2){
			$PASS=0;
		}
	}
	if($_ =~ /FS=(\d+\.?\d*)/){
		if($1 > 60){
			$PASS=0;
		}
	}
	if($_ =~ /MQ=(\d+\.?\d*)/){
		if($1 < 30){
			$PASS=0;
		}
	}
	if($_ =~ /MQRankSum=(\d+\.?\d*)/){
		if($1 < -12.5){
			$PASS=0;
		}
	}
	if($_ =~ /ReadPosRankSum=(\d+\.?\d*)/){
		if($1 < -8){
			$PASS=0;
		}
	}
	if($_ =~ /DP=(\d+\.?\d*)/){
		if($1 < 5 || $1 > 100){
			$PASS=0;
		}
	}
	if($PASS == 0){
		$FLT="FAIL";
	}else{
		$FLT="PASS";
	}
	if($flt eq "\."){
		$flt=$FLT;
	}
	if($flt eq "LowQual"){
		if($PASS == 0){
			$flt="LowQual;FAIL";
		}else{
			$flt="LowQual;PASS";
		}
	}
	$l[6]=$flt;
	$newLine=join("\t", @l);
	print OUT "$newLine\n";
}

close(IN);
close(OUT);

