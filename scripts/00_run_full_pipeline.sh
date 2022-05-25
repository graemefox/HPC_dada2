#!/bin/bash
## run the full pipeline with a single command

#SBATCH --job-name=00_full_dada2_pipeline
#SBATCH --output=00_full_dada2_pipeline.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=8GB
#SBATCH --time=24:00:00

######################################################

usage="
The user MUST supply:\n
\t - the directory of raw data files (-D)
\t - an email address to receive plot pdfs and job notifications (-E)
\t - the forward primer sequence used to generate amplicons (-F)
\t - the reverse primer sequence used to generate amplicons (-R)
\t - a correctly formatted fasta reference database to assign taxonomy to ASVs (-B)
\n\n
The user may optionally supply:\n
\t - the R1 specific section of the file names (these are generally automatically detected by the script) (-W)
\t - the R2 specific section of the file names (these are generally automatically detected by the script) (-P)
\t - the minimum length of a read allowed by Cutadapt (-M)
\t - the maximum number of occurences of an adapter to be removed by Cutadapt (-N)
\t - the length at which read 1 (R1) should be truncated by the dada2 function filterAndTrim (-T)
\t - the length at which read 2 (R2) should be truncated by the dada2 function filterAndTrim (-S)
\t - the maxEE (max number of errors allowed in read 1 (R1) for dada2: filterAndTrim (-G)
\t - the maxEE (max number of errors allowed in	read 2 (R2) for dada2: filterAndTrim (-H)
\t - truncQ: the minimum quality score after which a read should be truncated for dada2: filterAndTrim (-Q)
\t - the minimum length of read allowed for dada2: filterAndTrim (-L)"


## parse arguments
while getopts D:W:P:E:F:R:M:N:T:S:G:H:Q:L:B: flag
do
  	case "${flag}" in
                D) directory=${OPTARG};;
                W) R1_extension=${OPTARG};;
                P) R2_extension=${OPTARG};;
                E) email=${OPTARG};;
		F) forward=${OPTARG};;
		R) reverse=${OTPARG};;
                M) minimum=${OPTARG};;
                N) copies=${OPTARG};;
		T) trunclen1=${OPTARG};;
		S) trunclen2=${OPTARG};;
		G) maxEE1=${OPTARG};;
		H) maxEE2=${OPTARG};;
		Q) truncQ=${OPTARG};;
		L) minlength=${OPTARG};;
		B) database=${OPTARG};;
        esac
done

######################################################
## check mandatory arguments
if [ ! "$directory"] ; then
        printf "\n\nERROR: Argument -D (directory of raw data files) must be provided"
        printf "\n\nERROR: Argument -E (contact email address) must be provided"
        printf "\n\nERROR: Argument -F (forward primer sequence) must be provided"
        printf "\n\nERROR: Argument -R (reverse primer sequence) must be provided"
	printf "\n\nERROR: Argument -B (reference database) must be provided"
        printf "\n\n$usage" >&2; exit 1
fi

######################################################
# Remove Ns
## build up arg string to pass to R script
ARGS=""
if [ "$directory" ]; then ARGS="$ARGS -D $directory"; fi
if [ "$R1_extension" ]; then ARGS="$ARGS -W $R1_extension"; fi
if [ "$R2_extension" ]; then ARGS="$ARGS -P $R2_extension"; fi
if [ "$email" ]; then ARGS="$ARGS -E $email"; fi

## load R and call Rscript
module load R/4.0.0-foss-2020a
Rscript $PWD/scripts/01_remove_Ns.R $ARGS

######################################################
# Run Cutadapt
## build up arg string to pass to R script
ARGS=""
if [ "$dir" ]; then ARGS="$ARGS -D $dir"; fi
if [ "$forward" ]; then ARGS="$ARGS -F $forward"; fi
if [ "$reverse" ]; then ARGS="$ARGS -R $reverse"; fi
if [ "$minimum" ]; then ARGS="$ARGS -M $minimum"; fi
if [ "$copies" ]; then ARGS="$ARGS -N $copies"; fi
if [ "$email" ]; then ARGS="$ARGS -E $email"; fi

## load R and call Rscript
source ~/.bash_profile
conda activate cutadapt
module load R/4.0.0-foss-2020a
Rscript $PWD/scripts/02_cutadapt.R $ARGS

######################################################
# Generate quality plots
## build up arg string to pass to R script
ARGS=""
if [ "$email" ]; then ARGS="$ARGS -E $email"; fi

## load R and call Rscript
module load R/4.0.0-foss-2020a
Rscript $PWD/scripts/03_raw_quality_plots.R $ARGS

######################################################
# Run filterAndTrim
## build up arg string to pass to R script
ARGS=""
if [ "$email" ]; then ARGS="$ARGS -E $email"; fi
if [ "$trunclen1" ]; then ARGS="$ARGS -T $trunclen1"; fi
if [ "$trunclen2" ]; then ARGS="$ARGS -S $trunclen2"; fi
if [ "$maxEE1" ]; then ARGS="$ARGS -F $maxEE1"; fi
if [ "$maxEE2" ]; then ARGS="$ARGS -G $maxEE2"; fi
if [ "$truncQ" ]; then ARGS="$ARGS -Q $truncQ"; fi
if [ "$minlength" ]; then ARGS="$ARGS -L $minlength"; fi


## load R and call Rscript
module load R/4.0.0-foss-2020a
Rscript $PWD/scripts/04_filterAndTrim.R $ARGS

######################################################
# Generate error model(s)
## build up arg string to pass to R script
ARGS=""
if [ "$email" ]; then ARGS="$ARGS -E $email"; fi

## load R and call Rscript
module load R/4.0.0-foss-2020a
Rscript $PWD/scripts/05_generate_error_model.R $ARGS

######################################################
## build up arg string to pass to R script
ARGS=""
if [ "$email" ]; then ARGS="$ARGS -E $email"; fi

## load R and call Rscript
module load R/4.0.0-foss-2020a
Rscript $PWD/scripts/06_derep_dada2_merge_remove_chimeras.R $ARGS

#################################################
## build up arg string to pass to R script
ARGS=""
if [ "$email" ]; then ARGS="$ARGS -E $email"; fi

## load R and call Rscript
module load R/4.0.0-foss-2020a
Rscript $PWD/scripts/07_sequence_tracking.R $ARGS

######################################################
## parse arguments
while getopts B:E: flag
do
  	case "${flag}" in
                B) database=${OPTARG};;
                E) email=${OPTARG};;
        esac
done

## build up arg string to pass to R script
ARGS=""
if [ "$database" ]; then ARGS="$ARGS -B $database"; fi
if [ "$email" ]; then ARGS="$ARGS -E $email"; fi

## load R and call Rscript
module load R/4.0.0-foss-2020a
Rscript $PWD/scripts/08_assign_taxonomy.R $ARGS
