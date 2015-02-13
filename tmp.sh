echo "Type the number of the right BiBTeX reference or press [n] for the next 20 results."
  read answer

  # count the number of lines of tmp2 file
  NOL=$(cat tmp2 | wc -l)
  
  # Verify if $answer is a number to create the .bib file
  if [ $answer -lt 1000 ]; then
    # Search in file tmp2 for the chosen number
    cat tmp2 | awk -v answer="$answer" -v NOL="$NOL" '{if ($1=="["answer"]") {getline; while ($1!="["answer+1"]" && NR<NOL) {print $0; getline; if (NR==NOL) print $0}}}'
    echo
    echo "You can copy and paste the reference above or, later on, read it from the file library.bib"
    echo
  fi
