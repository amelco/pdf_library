#!/bin/bash
#
##########################################################################################################################################
# User oriented program that sweeps all pdf files of a directory and
# makes OCR, asking for the proper variables values.
#
### OBS.: In this first version:
# * the script has to be located in the same directory of the pdfs;
# * a new directory is created to store the renamed pdf files;
# * the renamed pdf files are COPIED to the new directory, so you still have the files with the original names;
# * a temporary txt file (filenames.txt) is created with the names of the original pdf files. The script deletes this file in the end
# * a temporary txt file (tmp.txt) containing the OCRed pdf text is created. The script deletes this file in the end
#
##########################################################################################################################################
#
# Developed by Andre Herman
#
### TO DO:
# * hability to stop in the middle of the process and, later, begin where it has stopped
# * hability to go back to the previous entry to correct some mistake ocasionally made
##########


## For further version: the directory that contains the pdf files is asked if no argument is given
#if [ $# -eq 0 ]; then
#  # No arguments supplied
#  echo "Type the path of the directory containing the PDFs you want to put in the database:"
#  read -r dir
#else
#  # First argument is the directory
#  dir=$1
#fi
#

#### Parameters that can be changed by the user ###################################
# new database filename
newDBfilename='newDB.txt'
# new directory for the renamed pdf files
newdir='renamed_pdfs'
# number of lines of the current pdf file to be shown on the screen at once
inc=40
###################################################################################



#### Beginning of the process. User can not change anything here##################

#cleaning and creating the newdatabase file
echo "" > $newDBfilename
# creates a txt file with all pdf filenames (full extension)
ls *.pdf > filenames.txt
#asks for last number of pdf file of the original database
echo "What is the last number of the database?"
read -r id
#creates a new directory to store the renamed pdf files
mkdir $newdir

OLDIFS=$IFS
IFS=$'\n'
for line in $(cat filenames.txt)
do
### Beginning of the loop ################
# OCR the file to a temporary txt file
echo
echo "OCRing the next file... please wait"
pdftotext ${line} tmp.txt
echo
echo "OCR complete!"

tot_lines=$(cat tmp.txt | wc -l)	# total of lines in the OCRed file
li=0					# initial line
le=$inc					# end line
key="n"					# key pressed ('n' is default => [n]ext)

#echo
#echo "#lines: ${tot_lines}"
#read

# scans tmp.txt file at each $inc lines
while [ $li -le "$((tot_lines))" ]; do
  clear
  awk "NR>=${li}&&NR<=${le}{print;}" tmp.txt 
  echo
  echo "======================================="
  printf "[p]revious; [s]top; [n]ext "
  read -r -n1 key
  echo
  if [ "$key" = "s" ] || [ "$key" = "S" ]; then
    break
  elif [ "$key" = "p" ] || [ "$key" = "P" ]; then
    li=$((li - inc))
    le=$((le - inc))
  elif [ "$key" = "n" ] || [ "$key" = "N" ]; then
    li=$((li + inc))
    le=$((le + inc))
  else
    li=$((li + inc))
    le=$((le + inc))
  fi
done

echo "======================================="
echo "Write the variable values:"
echo 
printf "Title: "
read -r title
printf "Year: "
read -r year
printf "Author(s): "
read -r author
printf "Type ([p]aper; [b]ook; [o]ther):"
read -r -n1 key
  if [ "$key" = "p" ] || [ "$key" = "P" ]; then
    type='paper'
  elif [ "$key" = "b" ] || [ "$key" = "B" ]; then
    type='book'
  elif [ "$key" = "o" ] || [ "$key" = "O" ]; then
    type='other'
  else
    type='other'
  fi
echo
echo

echo $title
echo $author
echo $year
echo $type

# Further version: verify the last number of datafile (now, this is done with user input at the beginning of the script)
#id='101'
# Adicionar um novo registro no arquivo de dados
# copia PDF para novo diretorio, mantendo o PDF original
id=$((id+1))
newfilename="$id.pdf"

# Shows the new register that will be added in the new database file
echo
echo "$id;$newfilename;$type;$title;$author;$year"
echo "$id;$newfilename;$type;$title;$author;$year" >> $newDBfilename

# Copy and renames the pdf file to the new directory
cp $line "$newdir/$newfilename"

echo
echo "$line has been renamed to $newfilename and copied to $newdir/"
read
### End of loop ##########
done
IFS=$OLDIFS

cp "$newDBfilename $newdir/."
rm filenames.txt
rm tmp.txt
echo
echo "Database file $newDBfilename has been copied to $newdir/"
echo
echo "Done!"
echo
