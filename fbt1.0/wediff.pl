#!/usr/bin/perl -w 

#
# wediff.pl finds the edge-wise different between two graphs given 
# in .itm format 
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


unless ($#ARGV == 1) 
{
	die("Usage: wediff.pl file1.itm file2.itm ...\n"); 
}

$file1 = shift @ARGV; 
$file2 = shift @ARGV; 

my %file1hash = (); 
my %file2hash = (); 

open ("infile", "<$file1") || die "Cannot open $file1. $!\n"; 
while(<infile>) 
{
	chomp; 
	if (/--/)
	{
		s/\s+//g; 
		my @nodes = split(/--/);
		my $i;  
		for($i=0; $i<$#nodes; $i++)
		{
			my $j = $i+1; 
			my $key; 
			if ($nodes[$i] le $nodes[$j])
			{
				$key = "$nodes[$i]:$nodes[$j]"; 
			}
			else 
			{
				$key = "$nodes[$j]:$nodes[$i]"; 
			} 
			$file1hash{$key} = "u"; 
		}
	}
}
close ("infile"); 

open ("infile", "<$file2") || die "Cannot open $file2. $!\n"; 
while(<infile>) 
{
	chomp; 
	if (/--/)
	{
		s/\s+//g; 
		my @nodes = split(/--/);
		my $i;  
		for($i=0; $i<$#nodes; $i++)
		{
			my $j = $i+1; 
			my $key; 
			if ($nodes[$i] le $nodes[$j])
			{
				$key = "$nodes[$i]:$nodes[$j]"; 
			}
			else 
			{
				$key = "$nodes[$j]:$nodes[$i]"; 
			} 
			if ($file1hash{$key})
			{
				$file1hash{$key} = "c"; 
				$file2hash{$key} = "c"; 
			}
			else 
			{
				$file2hash{$key} = "u"; 
			}

		}
	}
}
close ("infile"); 

foreach $key (keys(%file1hash))
{
	my $edge = $key; 
	$edge =~ s/:/--/g; 
	print "< $edge\n" if $file1hash{$key} eq "u"; 
}

print "-----\n"; 

foreach $key (keys(%file2hash))
{
	my $edge = $key; 
	$edge =~ s/:/--/g; 
	print "> $edge\n" if $file2hash{$key} eq "u"; 
}

	
	
