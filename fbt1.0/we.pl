#! /usr/bin/perl -w 

#
# Count number of edges in input .dot,.itm file 
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


$sum = 0; 
$count = 0; 

unless ($#ARGV >= 0) 
{
    die "Usage: we <itmfiles>\n"; 
}

foreach $file (@ARGV) 
{
    $count = 0; 
    my $nodehash = {}; 
    open ("infile", "<$file");
    while (<infile>) 
    {
	#if (/^CND/)#blocked by sudip....15.05.2003 
	#{	    #blocked by sudip....15.05.2003
	    #my $path=$_; #blocked by srinath....20.06.2003
	    my @fields = split(/:/); 
	    my $path = $fields[$#fields]; 
	    #($tmp,$tmp,$path) = split(/:/); 
	    $path =~ s/\s+//g; 
	
	    my @nodes = split(/--/, $path); 

	    for ($i=0; $i<$#nodes; $i++) 
	    {
		my $elem; 

		if ($nodes[$i] lt $nodes[$i+1]) 
		{
			$elem = $nodes[$i] . ":" . $nodes[$i+1]; 
		}
		else 
		{
			$elem = $nodes[$i+1] . ":" . $nodes[$i]; 
		}
		unless ($nodehash->{$elem}) 
		{
		    $count ++; 
		    $nodehash->{$elem} = 1; 
		}
	    }
	#}	    #blocked by sudip....15.05.2003
	
    }
    close("infile"); 
    print "$count:$file\n" if $#ARGV > 0; 
    print "$count\n" unless $#ARGV > 0; 
    $sum += $count; 
}

print "Total:$sum \n" if $#ARGV > 0; 
