#!/bin/bash
# User oriented program that sweeps all pdf files of a directory and
# makes OCR, asking for the proper variables values.

filename='cushman_1979.pdf'		# name of the file to be OCRed
filename='s06.pdf'		# name of the file to be OCRed
filename='[Daniel_Hillel_(Auth.)]_Applications_of_Soil_Physi(BookZZ.org).pdf'		# name of the file to be OCRed
tot_lines=$(cat tmp.txt | wc -l)	# total of lines in the OCRed file
li=0					# initial line
inc=50					# increment
le=$inc					# end line
key="n"					# key pressed

# OCr the file to a temporary txt file
pdftotext ${filename} tmp.txt
echo
echo "#lines: ${tot_lines}"
read

# scans the file at each $inc lines
while [ $li -le "$((tot_lines))" ]; do
  clear
  awk "NR>=${li}&&NR<=${le}{print;}" tmp.txt 
  echo
  echo "======================================="
  echo "[p]revious; [s]top; [n]ext"
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
# Adicionar um novo registro no arquivo de dados
# renomear o PDF

#rm tmp.txt
