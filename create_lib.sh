#!/bin/bash
# User oriented program that sweeps all pdf files of a directory and
# makes OCR, asking for the proper variables values.

filename='cushman_1979.pdf'		# name of the file to be OCRed
tot_lines=$(cat tmp.txt | wc -l)	# total of lines in the OCRed file
li=0					# initial line
inc=50					# increment
le=$inc					# end line
key="n"					# key pressed

# OCr the file to a temporary txt file
pdftotext -f 1 -l 1 ${filename} tmp.txt

# scans the file at each $inc lines
while [[ "$le" != "$((tot_lines + inc))" ]]; do
  clear
  awk "NR>=${li}&&NR<=${le}{print;}" tmp.txt 
  li=$((li + inc))
  le=$((le + inc))
  echo
  echo "The variables can be found here (y/n)?"
  read -r -n1 key
  echo
  if [ "$key" = "y" ] || [ "$key" = "Y" ]; then
    break
  fi
done

# 
echo "Write the variable values:"
echo 
printf "Title: "
read -r title
printf "Year: "
read -r year
printf "Author: "
read -r author
printf "Type ([p]aper; [b]ook; [o]ther):"
read -r -n1 key
  if [ "$key" = "p" ] || [ "$key" = "P" ]; then
    type='Paper'
  elif [ "$key" = "b" ] || [ "$key" = "B" ]; then
    type='Book'
  elif [ "$key" = "o" ] || [ "$key" = "O" ]; then
    type='Other'
  else
    type='Other'
  fi
echo
echo

echo $title
echo $author
echo $year
echo $type

# Verificar o ultimo numero do arquivo de dados
# Adicionar um novo registro nbo arquivo de dados
