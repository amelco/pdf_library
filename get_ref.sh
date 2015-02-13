#----------------------------------------------------------------------------------#
#!/bin/bash
# Automated aquiring of BiBTeX references through google scholar
# Developed by: Andre Herman
# January, 2014
#
# Need to execute elinks first to configure google scholar to show bibtex entries
#----------------------------------------------------------------------------------#

#-- Changes -----------------------------------------------------------------------#
# April, 2014 --> 	Changed terminal browser from lynx to elinks.
#			Changed site from BibSonomy to Google Scholar.
#			Improved search from file tmp2.
#----------------------------------------------------------------------------------#

# First argunent is the query string. Spaces must be replaced by a '+' sign.
query=$1
url='http://scholar.google.com.br/scholar?hl=en&q='
answer='n'
page='&start='
number=0

#Verify if the package elinks is installed
dpkg -s 'elinks' > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo
  echo "You have to install elinks. Try: sudo apt-get install elinks"
  echo
  exit 0
fi
  
while [ $answer == 'n' ]; do
  echo 
  echo "Using website Google Scholar"
#  echo "URL: $url$query"
  echo "Query: $query"
  echo
  echo "Searching for references..."
  echo
  
  # The file tmp has all links to bibtex entries
  elinks -dump $url$query$page$number | grep .bib | awk '{print $2}' > tmp
  
  # Verify if the file tmp is empty. If so, get out from while
  if [ -s tmp ]; then 
    echo  
  else 
    echo ""
    echo
    echo "Search returned ZERO results."
    break
  fi

  # Each result has a number and the user can chose the right one.
  rm tmp2 > /dev/null 2>&1
  for line in $(cat tmp); do
    echo "[$number]"
    # Show the reference list on the screen 
    elinks -dump $line 
    # Store the reference list in a file (tmp2)
    echo "[$number]" >> tmp2
    elinks -dump $line >> tmp2 
    echo
    number=$[$number+1]
  done
  echo
  echo "Type the number of the right BiBTeX reference or press [n] for the next 10 results."
  read answer

  # count the number of lines of tmp2 file
  NOL=$(cat tmp2 | wc -l)
  
  # Verify if $answer is a number to create the .bib file
  if [ $answer -lt 1000 ]; then
    # Search in file tmp2 for the chosen number
    cat tmp2 | awk -v answer="$answer" -v NOL="$NOL" '{if ($1=="["answer"]") {getline; while ($1!="["answer+1"]" && NR<NOL) {print $0; getline; if (NR==NOL) print $0}}}'
    cat tmp2 | awk -v answer="$answer" -v NOL="$NOL" '{if ($1=="["answer"]") {getline; while ($1!="["answer+1"]" && NR<NOL) {print $0; getline; if (NR==NOL) print $0}}}' >> ref.bib
    echo
    echo "You can copy and paste the reference above or, later on, read it from the file ref.bib"
    echo
    break
  fi 

  if [ $answer == 'n' ]; then
    echo
    echo "Searching for more 10 results..."
    echo
    $number=$number+10
  fi
done

#rm tmp; rm tmp2
