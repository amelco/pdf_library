# pdf_library
Program to manage academic papers (and relateds) 

The program is basically several bash scripts encapsulated in a FORTRAN program. 
The file main.f90 contains the structure of the program in which each action (subroutine) is one or more bash commands. It uses a lot of system calls to execute those commands or scripts.

The program simply links a text file containing title, author, year and type informations of a PDF file (database) to its respective PDF file.
All PDF files must be together in the same directory.
Once the text database is created, the program can:
* show to the user the pdf files sorted by author, year, title;
* do searches for words in author or title;
* do search for words inside the PDF text;
* get from internet the BiBTeX references;

The user can do some configuration in the program, like:
* Have several databases and select each one will be used;
* Chose a PDF viewer (evince or okular);

Some separated scripts, let us call them subprograms, are in the same directory of the main program. They are:
* get_ref.sh				: get BiBTeX references from internet 
* create_ini_database.sh	: create a initial sketch of the database file 
* create_lib.sh				: create a new register in the database file from a PDF file (user oriented)

*== TO DO section ==*
- script that creates automatically the pdf databse. The user just need to say in which directory the files are.
- execute automatically the script 'create_lib.sh' (in a terminal) every time a PDF file is downloaded (Chrome or Firefox plugin)
- and more to think about...
