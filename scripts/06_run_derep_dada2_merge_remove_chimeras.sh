#!/bin/bash

#SBATCH --job-name=06_derep_dada2_merge_remove_chimeras
#SBATCH --output=06_derep_dada2_merge_remove_chimeras.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=8GB
#SBATCH --time=24:00:00

## parse arguments
while getopts E:C: flag
do
	case "${flag}" in
		E) email=${OPTARG};;
		C) marker=${OPTARG};;
	esac
done

## build up arg string to pass to R script
ARGS=""
if [ "$email" ]; then ARGS="$ARGS -E $email"; fi
if [ "$marker" ]; then ARGS="$ARGS -C $marker"; fi

## load R and call Rscript
module load R/4.0.0-foss-2020a
Rscript $PWD/scripts/06_derep_dada2_merge_remove_chimeras.R $ARGS

 
