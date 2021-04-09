#!/usr/bin/env Rscript

# Code by Fátima Sánchez-Barreiro
# Plotting local estimates of heterozygosity in sliding windows alongside RoH identified with BCFtools RoH


args = commandArgs(trailingOnly=TRUE)

# test if all arguments have been supplied: 2 input files and one output name prefix; if not, return an error
if (length(args)==0) {
  stop("Three arguments must be supplied:input het in windows file, input RoH file and an output prefix).n", call.=FALSE)
} else if (length(args)==1) {
  stop("Three arguments must be supplied:input het in windows file, input RoH file and an output prefix).n", call.=FALSE)
} else if (length(args)==2) {
  stop("Three arguments must be supplied:input het in windows file, input RoH file and an output prefix).n", call.=FALSE)
}



# Load required libraries
library(ggplot2)
library(cowplot)
library(reshape2)
library(dplyr)
library(tidyverse)
require(scales)
library(ggpubr)
library(tidyr)


# Read in tables

print("Reading in input data")

## Het in windows from GT calls with Marc's method
windowhet = read.table(args[1], h=F, fill=T, stringsAsFactors=T, fileEncoding="latin1")
colnames(windowhet) = c('chrom', 'midpoint', 'hetSites', 'totalSites', 'Het', 'sample')


## BCFtools RoH results
bcf = read.table(args[2], h=F, fill=T, stringsAsFactors=T, fileEncoding="latin1")
colnames(bcf) = c('type', 'sample', 'chrom', 'start', 'end', 'length', 'n_markers', 'quality')


print("Prepping for visualization")

# Add a 'y' variable to the bcf table so it can be plotted along with het along the scaffold
bcf$y = 0.006


# Make a common x axis representing the positions along the scaffold
## The largest scaffold JH767723 is 79733107 bp long
chrom = as.data.frame(seq(from=1, to=79733107))
colnames(chrom) = c("position") 


print("Producing pretty plots")

# Visualize both together 
# but zoom into each of the two parts of the y scale
P = ggplot(chrom, aes(position)) + theme_bw() + scale_y_continuous(limits=c(0,0.007)) +
  geom_point(data=windowhet, aes(x=midpoint, y=Het), color='royalblue4', size=0.5) + geom_line(data=windowhet, aes(x=midpoint, y=Het), color='royalblue4') +
  geom_segment(data=bcf, aes(x=start, xend=end, y=y, yend=y), size=15, colour="darkorange") +
  theme(axis.text=element_text(size=12), axis.title=element_text(size=12)) +
  xlab("Position along scaffold (bp)") +
  ylab("Heterozygosity")


# Arrange both plots by stacking them together in one column and save as pdf
pdf(paste(args[3],".seeRoh.pdf", sep=''), height=5, useDingbats = F)
P
dev.off()
