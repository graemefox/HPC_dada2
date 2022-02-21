# HPC_dada2
## Example workflow to run a dada2 analysis using The University of Sheffield BESSEMER HPC.

<summary>1) About</summary>
<details>
<summary>About, credits, and other information</summary>

This HPC tutorial is based largely upon the dada2 (v.1.8) tutorial published by
Benjamin Callahan on the dada2 GitHub page
(https://benjjneb.github.io/dada2/tutorial_1_8.html).

The core of the data processing is identical to that in the above, with modifications
to allow it to be easily run on a remote HPC system.

Whilst it has been written for use with The University of Sheffield's
[BESSEMER](https://docs.hpc.shef.ac.uk/en/latest/bessemer/index.html) system,
the below should be applicable to any GNU/Linux based HPC system, with
appropriate modification (your mileage may vary).

Code which the user (that's you) must run is highlighted in a code block like this:
```
I am code - you must run me
```

Filepaths are highlighted within normal text like this:

`/home/user/a_file_path`

Contact: Graeme Fox //  g.fox@sheffield.ac.uk // graeme.fox87@gmail.com // [@graefox](https://twitter.com/graefox)

</details>

<summary>2) Getting Started - Access the HPC, and load the required software and data.</summary>
<details>
<summary>Access the HPC</summary>
<details>
To access the BESSEMER high-performance computer (HPC) you must be connected
to the university network - this can be achieved remotely by using the
virtual private network (VPN) service.

[Please see the university IT pages for details on how to connect to the VPN.](https://students.sheffield.ac.uk/it-services/vpn)

Once connected to the VPN you also need to connect to the HPC using a secure shell (SSH)
connection. This can be achieved using the command line (advanced) or software
such as [MobaXterm](https://mobaxterm.mobatek.net/).

[See the university pages for guidance on how to connect to the VPN](https://docs.hpc.shef.ac.uk/en/latest/hpc/index.html).
</details>
<summary>Access a worker node on BESSEMER</summary>
<details>
Once you have successfully logged into BESSEMER, you need to access a worker node:

```
srun --pty bash -l
```
You should see that the command prompt has changed from

```
[<user>@bessemer-login2 ~]$
```
to
```
[<user>@bessemer-node001 ~]$
```
...where \<user\> is your The University of Sheffield (TUoS) IT username.
Wherever \<user\> appears in this document, substitute it with your University of Sheffield (TUoS) IT username.

<summary>Load the Genomics Software Repository</summary>

The Genomics Software Repository contains several pre-loaded pieces of software
useful for a range of genomics-based analyses, including this one.

Did you receive the following message when you accessed the worker node?
```
Your account is set up to use the Genomics Software Repository
```

If so, you are set up and do not need to do the following step.
If not, enter the following:
```
echo -e "if [[ -e '/usr/local/extras/Genomics' ]];\nthen\n\tsource /usr/local/extras/Genomics/.bashrc\nfi" >> $HOME/.bash_profile
```
...and then re-load your profile:
```
source ~/.bash_profile
```
Upon re-loading, you should see the message relating to the Genomics Software Repository above.

<summary>Create a working directory and load your data</summary>

You should work in the directory `/fastdata` on BESSEMER as this allows shared access to your files
and commands, useful for troubleshooting.

Check if you already have a directory in `/fastdata`.

```
ls /usr/<user>
```

If you receive the message
```
ls: cannot access /fastdata/<user>: No such file or directory
```
Then you need to create a new folder in `/fastdata` using the command exactly as it appears below:

```
mkdir -m 0700 /fastdata/$USER
```

Create new subdirectories to keep your scripts and data files organised:
```
mkdir /fastdata/$USER/my_project
mkdir /fastdata/$USER/my_project/scripts
mkdir /fastdata/$USER/my_project/raw_data
mkdir /fastdata/$USER/my_project/working_data
```

<summary>Data file naming convention</summary>

The workflow assumes that the `/fastdata/my_project/raw_data` directory contains sequence data that is:

* Paired (two files per biological sample)

* Demultiplexed

* FASTQ format

* (optional, but recommended) in the compressed .gz format

Each pair of files relating to each biological sample should have the following naming convention:

`<sample_ID>_S<##>_R1_001.fastq.gz`

`<sample_ID>_S<##>_R2_001.fastq.gz`

Where <sample_ID> is a unique identifier, and S<##> is a sample number (generally assigned by the sequencer itself).

For example, a pair of files might look like this:

`SoilGB_S01_R1_001.fastq.gz`

`SoilGB_S01_R2_001.fastq.gz`

<summary>Load your raw sequence data</summary>

If you have sequenced your samples with NEOF, and have been notified that your data
has been received, then you should be able to find your data on the HPC server.

Data is generally stored in the shared space `/shared/molecol2/NBAF/MiSeq/`.

View the data directories contained within it and identify the one that belongs to you.
```
ls /shared/molecol2/NBAF/MiSeq/
```

If, for example, your data directory was called `NBAF_project_010122`, then you would
copy it onto your raw_data directory with the following:
```
cp -r /shared/molecol2/NBAF/MiSeq/NBAF_project_010122/ /fastdata/<user>/my_project/raw_data/
```

Alternatively, to copy data from your personal computer onto the HPC you need to use a file transfer
application such as 'scp' (advanced), MobaXterm, or [FileZilla](https://filezilla-project.org/).
Ensure to copy the data into your `/fastdata/my_project/raw_data folder`.

Run 'ls' on your `raw_data` folder and you should see something like the following

<summary>Copy the dada2 R scripts</summary>

Copy the required R scripts for the dada2 workflow into your `scripts`

```
cp /fastdata/bi1xgf/dada2_hpc_scripts/* /fastdata/<user>/scripts
```

<summary>3) Load data into R and perform preliminary filtering and quality trimming.</summary>
<summary>Section 01</summary>
<details>
module load R
/usr/local/packages/live/eb/R/4.0.0-foss-2020a/bin/R
</details>
