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


%adj = (); 
%colour = ();
$walklength = 1; 
%paths = ();  
@oldpath = (); 

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
	
	push @oldpath, ($line); 
	my @nodes = split(/--/,$line); 
	my $i; 
	$walklength = $#nodes + 1; 

	for ($i=0; $i<$#nodes; $i++) 
	{
		my $j = $i+1; 
		$adj{$nodes[$i]} .= "$nodes[$j] "; 
		$adj{$nodes[$j]} .= "$nodes[$i] "; 
		$colour{$nodes[$i]} = 0; 
		$colour{$nodes[$j]} = 0; 
	}
    }
    else 
	{}
}

#print STDERR "walklength = $walklength\n"; 
$newpaths = 0; 
foreach $path (@oldpath) 
{
	my @nodes = split(/--/, $path);
        my $i; 	
	my %ecolour = (); 
	for ($i=0; $i<=$#nodes; $i++)
	{
		$colour{$nodes[$i]} = 1; 
		if ($i < $#nodes)
		{
			my $edge = "$nodes[$i]:$nodes[$i+1]"; 
			my $redge = "$nodes[$i+1]:$nodes[$i]"; 
			$ecolour{$edge} = 1; 
			$ecolour{$redge} = 1; 
		}
	}
	$i = 0; 
	foreach $adjnode (split(/\s+/,$adj{$nodes[$i]}))
	{
		if ($colour{$adjnode} != 1)
		{
			my $newpath = "$adjnode--$path"; 
			my $rpath = reverse_path($newpath); 
			$newpath = $rpath if $newpath gt $rpath; 
			unless ($paths{$newpath})
			{
				print "$newpath\n"; 
				$paths{$newpath} = 1; 
				$newpaths ++; 
			}
		}
		elsif ($ecolour{"$nodes[$i]:$adjnode"} != 1)
		{
			my $newpath = "$adjnode--$path"; 
			my $rpath = reverse_path($newpath); 
			$newpath = $rpath if $newpath gt $rpath; 
			unless ($paths{$newpath})
			{
				print "$newpath\n"; 
				$paths{$newpath} = 1; 
				$newpaths ++;
			}
		}

	}
	$i = $#nodes; 
	foreach $adjnode (split(/\s+/,$adj{$nodes[$i]}))
	{
		if ($colour{$adjnode} != 1)
		{
			my $newpath = "$path--$adjnode"; 
			my $rpath = reverse_path($newpath); 
			$newpath = $rpath if $newpath gt $rpath; 
			unless ($paths{$newpath})
			{
				print "$newpath\n"; 
				$paths{$newpath} = 1; 
				$newpaths ++;
			}
		}
		elsif ($ecolour{"$nodes[$i]:$adjnode"} != 1)
		{
			my $newpath = "$path--$adjnode"; 
			my $rpath = reverse_path($newpath); 
			$newpath = $rpath if $newpath gt $rpath; 
			unless ($paths{$newpath})
			{
				print "$newpath\n"; 
				$paths{$newpath} = 1; 
				$newpaths ++;
			}
		}
	}
	for ($i=0; $i<=$#nodes; $i++)
	{
		$colour{$nodes[$i]} = 0; 
	}
}

print STDERR "newpaths=$newpaths\n"; 
