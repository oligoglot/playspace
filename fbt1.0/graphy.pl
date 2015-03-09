#!/usr/bin/perl -w

#
# FBT: A Filtration Based Technique for Mining Maximal Common Subgraphs
#
# Authors: Srinath Srinivasa (sri@iiitb.ac.in)
#          L. BalaSundaraRaman (balasundaraman.l@iiitb.ac.in)
#
# (c) Authors and the Indian Institute of Information Technology, Bangalore
#
# Please read the licence agreement carefully before using this code.
# Use of this code implies compliance with licence agreement.
#


$name = $ARGV[0] if $ARGV[0]; 
$name = "noname" unless $ARGV[0]; 
$name =~ s/\./\_/g; 

print "graph $name {\n";

while (<>)
{
	s/^CND:[^:]*://; 
	s/:.*$//; 
	print; 
}

print "}\n"; 

