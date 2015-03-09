#!/usr/bin/perl -w 

#
# nextgen: given a substructure, generate all possible paths of next 
# generation 
#
# Usage newnextgen.pl <candidatefilename> <.itm file>
#
# ..where next generation paths are merged into paths already present
# in candidate file name. 
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


require gram_init; 


sub dfsprint
{
	my $start = shift; 
	my $length = shift; 
	my $walk = shift; 

#	print STDERR "($start,$length,$walk) -- ($adj{$start})\n"; 
	if ($length < 0)
	{
		print STDERR "BUG!! length = $length\n"; 
		return; 
	}

	if ($length == 0) 
	{
		my $rwalk = reverse_path($walk); 
		$walk = $rwalk if $walk gt $rwalk; 
		unless ($paths{$walk})
		{
			print "$walk\n"; 
			$paths{$walk} = 1; 
		}
		return; 
	}
	
	$colour{$start} = 1; 
	foreach $adjnode (split(/\s+/,$adj{$start}))
	{
		if ($colour{$adjnode} == 0) 
		{
			$colour{$adjnode} = 1; 
			$colour{"$start:$adjnode"} = 1; 
			$colour{"$adjnode:$start"} = 1; 
			dfsprint($adjnode, $length-1, "$walk--$adjnode"); 
			$colour{$adjnode} = 0; 
			$colour{"$start:$adjnode"} = 0; 
			$colour{"$adjnode:$start"} = 0; 
		}
		elsif ($colour{"$adjnode:$start"} == 0) 
		{
			if ($length == 1)
			{
				$walk = "$walk--$adjnode"; 
				my $rwalk = reverse_path($walk); 
				$walk = $rwalk if $walk gt $rwalk; 
				unless ($paths{$walk})
				{
					print "$walk\n"; 
					$paths{$walk} = 1; 
				}
				return; 
			}
			else 
			{
				print STDERR "Cannot explore further on $walk--$adjnode\n"; 
			}
		}
	}
	$colour{$start} = 0; 
	print STDERR "Cannot explore further on $walk...\n"; 
	return; 
}
		

%adj = (); 
%colour = ();
$walklength = 1; 
%paths = ();  

while(<>) 
{
    chop; 
    if (/--/)
    {
	my $line = $_; 
	if (/:/) 
	{
	    my @l = split(/:/); 
	    $line = $l[$#l]; 
	}
#	print STDERR "$line\n"; 
	my @nodes = split(/--/,$line); 
	my $i; 
	$walklength = $#nodes + 1; 

	for ($i=0; $i<$#nodes; $i++) 
	{
		my $j = $i+1; 
		$adj{$nodes[$i]} .= "$nodes[$j] "; 
		$adj{$nodes[$j]} .= "$nodes[$i] "; 
		$colour{"$nodes[$i]"} = 0; 
		$colour{"$nodes[$j]"} = 0; 
		$colour{"$nodes[$i]:$nodes[$j]"} = 0; 
		$colour{"$nodes[$j]:$nodes[$i]"} = 0; 
	}
    }
    else 
	{}
}

print STDERR "walklength = $walklength\n"; 
my @adjlist = keys(%adj); 
foreach $node (@adjlist)
{
	#	for ($i=0; $i<$#adjlist; $i++)
	#	{
		#		$colour{"$adjlist[$i]:$adjlist[$i+1]"} = 0; 
		#	$colour{"$adjlist[$i+1]:$adjlist[$i]"} = 0; 
		#	}
	dfsprint($node, $walklength, "$node"); 
}

