#! /usr/bin/perl 

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


print "graph dot1 {\n";
my %graph;
while(<>)
{
	chomp;
	my @row = split /--/;
	for($i=0;$i<$#row;$i++)
	{
		$graph{"$row[$i]--$row[$i+1]"} = 1 unless $graph{"$row[$i+1]--$row[$i]"};
	}
}
foreach $ele(keys %graph)
{
	print "$ele;\n";	
}
print "}\n";
