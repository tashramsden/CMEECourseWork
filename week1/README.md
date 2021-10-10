# Week 1

**Topics covered this week:** UNIX and Linux, Shell scripting, LaTeX for scientific documents, and version control with Git.

Languages: Shell, LaTeX, (git)

Project structure: 10 script files in code directory (described below), some of which will manipulate files from data directory. Data directory contains sub-directories: fasta, LaTeX and temperatures. Results directory will be populated by running code files as described below.

## Code Files:

* **UnixPrac1.txt**
  * UNIX shell commands which perform calculations on data in FASTA files in week1/data/fasta.
  
* **boilerplate.sh**
  * First shell script; prints "This is a shell script!".
  
* **tabtocsv.sh**
  * Shell script that takes a tab-separated text file input and converts to a csv which will be saved in week1/results.
  
* **variables.sh**
  * Shell script exploring variable assignment; reads in a variable to be printed/numbers to be added.
  
* **MyExampleScript.sh**
  * More shell variable examples; prints welcome message for user.
  
* **CountLines.sh**
  * Shell script that takes one file as an input and returns the number of lines.
  
* **ConcatenateTwoFiles.sh**
  * Shell script that concatenates two files and saves the output file to week1/results.
  * Two files are required as inputs, these will be concatenated.
  * Optionally, a third argument can be given: this will be used as the name of the new file created in week1/results. If this argument is left blank the new file will be called concatenated_output.txt.
  
* **tiff2png.sh**
  * Shell script that will search for tiff files in a directory and convert them to pngs to be saved in week1/results.
  * By default the script will search for tiff files in week1/data (one example tiff is here).
  * Optionally, a relative path to a different directory can be provided and any tiff files here will be converted.

* **csvtospace.sh**
  * Shell script for converting csv files to space separated values files; all outputs will be saved to week1/results with .txt extension.
  * By default the script will search for .csv files in week1/data/temperatures, all of which will be converted.
  * Optionally, one argument can be passed to the script, either:
  * The relative path to a different directory - all csv files here will be converted, or
  * The name of one csv file to be changed to a space separated values file.

* **CompileLaTeX.sh**
  * Shell script that creates a LaTeX pdf and saves it to week1/results. 
  * Takes one argument: the name of the LaTeX .tex file which must be saved in week1/data/LaTeX.
  * Bibliography .bib file (if used) must also be saved in week1/data/LaTeX.
  
Tash Ramsden | tash.ramsden21@imperial.ac.uk