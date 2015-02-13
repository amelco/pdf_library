# List all files in the specified directory in a given format:
# id;filename;type;title;author;year
# ex.
# 1;0001.pdf;
# The user must complete the rest of the fields (type;title;author;year) manually
# ex.
# 1;0001.pdf;paper;A three-dimensional spatial model for plant competition in an heterogeneous soil environment;Mario Biondini;2001
#
# The file MUST have this format to be read by the program 
#
# Developed by: Andre Herman

path="/home/andre/Dropbox/doutorado/thesis/review/cited_papers"
ls -l $path | awk 'BEGIN {n=0;print "id;filename;type;title;author;year"} {print n";"$9";"} {n=n+1}'
