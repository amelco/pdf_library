aux='1'
ini_line='1'
end_line='1'

#for line in $(cat tmp2); do
while read line; do
  if [ $line == "[$1]" ]; then
    ini_line=$[$aux+1]
  fi
  if [ $line == "[$[$1+1]]" ]; then
    end_line=$[$aux-1]
  fi
  aux=$[$aux+1]
#  echo $line
done < tmp2 >/dev/null 2>&1

echo
sed -n "$ini_line,$end_line p;$end_line q" tmp2
