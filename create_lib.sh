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
### Modifications
# 09/03/2015:	* Added first argument as the directory for the PDF files
#		* Second argument is the database txt file that wants to add the new PDF files
#		* Added confirmation of the input arguments. If it is not correct, exits the script
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
if [ $# -lt 2 ]; then
  # No arguments supplied
  #echo "Type the path of the directory containing the PDFs you want to put in the database:"
  #read -r dir
  echo "No arguments were provided. Please give the following arguments:"
  echo "1 - relative or absolute directory of the PDF files that you want to add in the database"
  echo "2 - database text file (.dat) that you want to add the new entries"
  echo
  echo "Example: $0 /home/user/papers my_papers.dat"
  echo
  echo "Exiting script"
  echo
  exit
else
  # First argument is the directory
  rel_dir=$1
  # Second argument is the database file
  DB=$2
  # First char of the first argument
  fst_char=${rel_dir:0:1}
  lst_num=`awk -F ';' 'END{print $1}' $DB`
  # check if the directory is relative and changes it to absolute
  if [ $fst_char == "/" ]; then
    dir=$rel_dir
  else
    dir=`pwd`"/$rel_dir"
  fi
  # get length of $dir
  len=${#dir}
  # Last char of absolute directory
  # if it is not a '/', add it
  lst_char=${dir:$((len-1)):1}
  if [ $lst_char != "/" ]; then
    dir="$dir/"
  fi
fi


#### Parameters that can be changed by the user ###################################
# new database filename
newDBfilename='newDB.txt'
# new directory for the renamed pdf files
newdir=$dir"renamed_pdfs"
# number of lines of the current pdf file to be shown on the screen at once
inc=40
###################################################################################




#### Beginning of the process. User can not change anything here #################
clear
len=${#newdir}
lst_char=${newdir:$((len-1)):1}
if [ $lst_char != "/" ]; then
  newdir="$newdir/"
fi

echo
echo "-== VERIFICATION ==-"
echo
printf "%-28s: %${#dir}s\n" "Path of PDF files" "$dir"
printf "%-28s: %${#DB}s\n" "Database file" "$DB"
printf "%-28s: %${#lst_num}s\n" "Last # in database" "$lst_num"
printf "%-28s: %${#newdir}s\n" "Path to store renamed PDFs" "$newdir"
echo 
echo "==============="
echo
echo "Is this information correct? [y/N]"
read -r -n1 iniParam
if [ "$iniParam" = "n" ] || [ "$key" = "N" ]; then
  echo
  echo "Execute the script again with the correct arguments. Type $0 for a description"
  echo
  echo "Exiting script"
  exit
fi

#change to the directory where the PDFs are
cd $dir
#doing backup of the original database
cp $DB $DB".bkp"
#cleaning and creating the newdatabase file
echo "" > $newDBfilename
# creates a txt file with all pdf filenames (full extension)
ls *.pdf > filenames.txt
#asks for last number of pdf file of the original database
#echo "What is the last number of the database?"
#read -r id
id=$lst_num
#creates a new directory to store the renamed pdf files
mkdir $newdir

OLDIFS=$IFS
IFS=$'\n'
### Beginning of the loop ################
for line in $(cat filenames.txt)
  do
  # OCR the file to a temporary txt file
  echo
  echo "OCRing the next file... please wait"
  pdftotext ${line} tmp.txt
  echo
  echo "OCR complete!"
  
  tot_lines=$(cat tmp.txt | wc -l)	# total of lines in the OCRed file
  li=0					# initial line
  le=$inc				# end line
  key="n"				# key pressed ('n' is default => [n]ext)
  
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
  
  # Increments the file id and atributes the new file name
  id=$((id+1))
  newfilename="$id.pdf"
  
  # Shows the new register that will be added in the new database file, and add it
  echo
  echo "$id;$newfilename;$type;$title;$author;$year"
  echo "$id;$newfilename;$type;$title;$author;$year" >> $newDBfilename
  echo "$id;$newfilename;$type;$title;$author;$year" >> $DB
  # Copy and renames the pdf file to the new directory
  cp $line "$newdir/$newfilename"
  
  echo
  echo "$line has been renamed to $newfilename and copied to $newdir"
done
### End of loop ##########
IFS=$OLDIFS

cp "$newDBfilename $newdir""."
rm filenames.txt
rm tmp.txt
echo
echo "Database file $newDBfilename has been copied to $newdir"
echo
echo "Done!"
echo
