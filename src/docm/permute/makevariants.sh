#!/bin/bash

V_FILE=$1
OUT_FILE=$2
SPAN=$3

# grab SNPs | remove header | sort file and keep unique variants | create bed file with variants in base 0 | \
# print +/- $SPAN nucleotides around the canonical mutation position | sort file and keep unique variants | \
# getting fasta file with reference bases from bedtools and passing to stdout | \
# changing fasta to bed file with reference bases and converting file to base 1 | \
# composing all possible nucleotide variations | \

cat $V_FILE | grep SNP | cut -f -3 | sort -u | awk '{OFS="\t"; print $1,$2-1,$3}' | \
awk -v span=$SPAN 'BEGIN { print "Span is "span>"/dev/stderr" } {OFS="\t"; for(i=-span; i<=span; i++) { print $1,$2+i,$3+i } }' | sort -k1,1 -k2,2n -u | \
bedtools getfasta -fi /gscmnt/sata420/info/model_data/2857786885/build102671028/all_sequences.fa -bed stdin -fo stdout  > t2
cat t2 | tr "\n" "\t" | tr ">" "\n" | tail -n +2 | awk '{OFS="\t"; split($0,x,":"); split (x[2],y,"-"); print x[1],y[1]+1,y[2]}' | cut -f-4 > t3
cat t3 | awk '{OFS="\t"; if($4=="A") print $0,"C\n" $0, "G\n" $0, "T"; if($4=="C") print $0,"A\n" $0, "G\n" $0, "T"; if($4=="G") 
print $0,"A\n" $0, "C\n" $0, "T"; if($4=="T") print $0,"A\n" $0, "C\n" $0, "G"}' | sort -u | sort -k1,1 -k2,2n > var.tsv 

#annotating the variant file
gmt annotate transcript-variants --variant-file=var.tsv --output-file=annotate.out --reference-transcripts=NCBI-human.ensembl/74_37 --annotation-filter=top

#appending the annotated file without silent and intronic mutations to the original docm canonical mutants with corresponding columns
cat annotate.out | grep -v silent | grep -v intronic | awk '{OFS="\t"; print $1,$2,$3,$4,$5,$6,$7,$8,$24,$12,$14,$15,$16,"0" }' > annotate.sort.out

#script to set primary value of all canonical DoCM variants to 1 and permuted variants to 0
python selectPrimary.py $V_FILE annotate.sort.out DOCM_permuted.tsv

#sort the final file
cat DOCM_permuted.tsv | sort -k1,1 -k2,2n | sort -u > DOCM_permuted_sorted.tsv

#adding the header
echo -e "chromosome_name\tstart\tstop\treference\tvariant\ttype\tgene_name\ttranscript_name \
\tensembl_gene_id\tstrand\ttrv_type\tc_position\tamino_acid_change\tprimary" | cat - DOCM_permuted_sorted.tsv > $2

#removing all temporary files
rm t2 t3 var.tsv annotate.out annotate.sort.out DOCM_permuted.tsv DOCM_permuted_sorted.tsv
