#!/usr/bin/perl -w 

#
# Remove big blobs 
# SYNOPSIS
#        rmbb.pl clusterfile
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

#
# Main program 
#

my $numgraphs = countgraphs(); 
print STDERR "Numgraphs = $numgraphs\n"; 
die("Cannot determine the number of graphs... $!\n") if $numgraphs <= 0; 

sub countunique
#
# Count the number of unique files in a cluster 
#
{
	my $filelist = shift; 
	my $sum = 0; 
	my %filehash = (); 

	foreach $filename (@$filelist)
	{
		$filename =~ /^([^\.]*)\..*/;
		my $id = $1; 
		unless ($filehash{$id})
		{
			$filehash{$id} = 1; 
			$sum += 1; 
		}
	}
	return $sum; 
}

while (<>) 
{
    if (/^Cluster\s*[0-9]+/) 
      {
	my ($c,$elems) = split(/:/); 
	$c =~ s/^\s+//; 
	$c =~ s/\s+$//; 
	$elems =~ s/^\s+//; 
	$elems =~ s/\s+$//; 

	my @files = split(/\s+/,$elems); 
	my $ffile = $files[0]; 
	my $size; 

	if ($mmode eq "C")
	{
		$size = countunique(\@files); 
	}
	else 
	{
		$size = $#files + 1;
	}

	if ($size/$numgraphs < $ms)
	{
		print STDERR "Removing $c: size=$size, numgraphs=$numgraphs, minsup=$ms...\n"; 
		foreach $ffile (@files)
		{
			system("mv $ffile $ffile.bb"); 
		}
	}
      }
}

