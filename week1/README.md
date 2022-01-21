# Week 1

**Topics covered this week:** [UNIX and Linux](https://mhasoba.github.io/TheMulQuaBio/notebooks/01-Unix.html), [Shell scripting](https://mhasoba.github.io/TheMulQuaBio/notebooks/02-ShellScripting.html), [LaTeX for scientific documents](https://mhasoba.github.io/TheMulQuaBio/notebooks/04-LaTeX.html), and [version control with Git](https://mhasoba.github.io/TheMulQuaBio/notebooks/03-Git.html).

Languages: Bash (version 5.0.17(1)), LaTeX (pdfTeX version 3.14159265-2.6-1.40.20), (git).

Project structure: 12 script files in code directory (described below), some of which will manipulate files from data directory. Data directory contains sub-directories: fasta, (LaTeX) and temperatures. Results directory will be populated by running code files as described below.

Required package: [`imagemagick`](https://imagemagick.org/index.php)

## Code Files:

* [**UnixPrac1.txt**](code/UnixPrac1.txt)
  * UNIX shell commands which perform calculations on data in FASTA files in week1/data/fasta.
  
* [**boilerplate.sh**](code/boilerplate.sh)
  * First shell script; prints "This is a shell script!".
  
* [**tabtocsv.sh**](code/tabtocsv.sh)
  * Shell script that takes a tab-separated text file input and converts to a csv which will be saved in the same location as the input file.
  
* [**variables.sh**](code/variables.sh)
  * Shell script exploring variable assignment; reads in a variable to be printed/numbers to be added.
  
* [**MyExampleScript.sh**](code/MyExampleScript.sh)
  * More shell variable examples; prints welcome message for user.
  
* [**CountLines.sh**](code/CountLines.sh)
  * Shell script that takes one file as an input and returns the number of lines.
  
* [**ConcatenateTwoFiles.sh**](code/ConcatenateTwoFiles.sh)
  * Shell script that concatenates two files and saves the output file to week1/results.
  * Two files are required as inputs, these will be concatenated.
  * Optionally, a third argument can be given: this will be used as the name of the new file created in week1/results. If this argument is left blank the new file will be called concatenated_output.txt.
  
* [**tiff2png.sh**](code/tiff2png.sh)
  * Shell script that will search for tiff files in a directory and convert them to pngs to be saved in the same location.
  * By default the script will search for tiff files in week1/data (one example tiff is here).
  * Optionally, a relative path to a different directory can be provided and any tiff files here will be converted.
  * Requires installation of [`imagemagick`](https://imagemagick.org/index.php)

* [**csvtospace.sh**](code/csvtospace.sh)
  * Shell script for converting csv files to space separated values files; all .ssv outputs will be saved to the same directory as the inputs.
  * By default the script will search for .csv files in week1/data/temperatures, all of which will be converted.
  * Optionally, one argument can be passed to the script, either:
  * The relative path to a different directory - all csv files here will be converted, or
  * The name of one csv file to be changed to a space separated values file.

* [**CompileLaTeX.sh**](code/CompileLaTeX.sh)
  * Shell script that creates a LaTeX pdf and saves it to week1/results. 
  * Takes one argument: the name of the LaTeX .tex file which must be saved in the working directory.
  * Bibliography .bib file (if used) should also be saved here (but does not need to be passed as an argument).

* [**FirstExample.tex**](code/FirstExample.tex)
    * LaTeX file to be compiled by [CompileLaTeX.sh](code/CompileLaTeX.sh).

* [**FirstBiblio.bib**](code/FirstBiblio.bib)
    * LaTeX bibliography file which will be used to produce the bibliography for the LaTeX pdf output created by [CompileLaTeX.sh](code/CompileLaTeX.sh).

## Author

Tash Ramsden | tash.ramsden21@imperial.ac.uk
