#!/usr/bin/perl -w

#
# synthetic.pl : generate synthetic labeled graphs 
#

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


$numlabels = 4; 
$numgraphs = 100; 
$edgelimit = 100; 

for ($i=0; $i<$numgraphs; $i++)
{
	my $numedges = int(rand($edgelimit));
	system("./graphgen.pl $numlabels $numedges name=syn.$i type=s > syn.$i.dot"); 
}

