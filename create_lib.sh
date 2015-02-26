#!/bin/bash
# User oriented program that sweeps all pdf files of a directory and
# makes OCR, asking for the proper variables values.

### Initialy, put the script into the directory of the pdfs
#if [ $# -eq 0 ]; then
#  # No arguments supplied
#  echo "Type the path of the directory containing the PDFs you want to put in the database:"
#  read -r dir
#else
#  # First argument is the directory
#  dir=$1
#fi
#

# creates a txt file with all pdf filenames (full extension)
ls *.pdf > filenames.txt
#asks for last number of pdf file of the original database
echo "What is the last number of the database?"
read -r id
#creates a new directory to store the renamed pdf files
new_dir='renamed_pdfs'
mkdir $new_dir

OLDIFS=$IFS
IFS=$'\n'
for line in $(cat filenames.txt)
do
#Beginning of the loop #############################################################
# OCr the file to a temporary txt file
pdftotext ${line} tmp.txt

tot_lines=$(cat tmp.txt | wc -l)	# total of lines in the OCRed file
li=0					# initial line
inc=40					# increment
le=$inc					# end line
key="n"					# key pressed

#echo
#echo "#lines: ${tot_lines}"
#read

# scans the file at each $inc lines
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

# 
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

# Verificar o ultimo numero do arquivo de dados - now done with user inpit at the beginning of the script
#id='101'
# Adicionar um novo registro no arquivo de dados
# copia PDF para novo diretorio, mantendo o PDF original
id=$id+1
newfilename='0101.pdf'

echo
echo "$id;$newfilename;$type;$title;$author;$year"
############################################################################
done
IFS=$OLDIFS
#rm tmp.txt
