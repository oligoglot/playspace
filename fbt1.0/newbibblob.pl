#!/usr/bin/perl -w 

#
# Remove big blobs 
# SYNOPSIS
#        bigblob.pl clusterfile
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

@blobs = (); 
%clusters = (); 
%dims = (); 

sub diff
#
# diff between 2 array refs 
#
  {
    my $ref1 = shift; 
    my $ref2 = shift; 
    my $elem; 
    my $diffhash = (); 

    foreach $elem (@$ref1) 
      {
	$diffhash{$elem} = 1; 
      }
    foreach $elem(@$ref2)
      {
	if ($diffhash{$elem})
	  {
	    $diffhash{$elem} = 0; 
	  }
	else 
	  {
	    $diffhash{$elem} = 1; 
	    }
      }

    my $sum = 0; 
    foreach $elem (keys(%diffhash))
      {
	$sum++ if $diffhash{$elem} == 1; 
      }
    return $sum; 
}

#
# Main program 
#

while (<>) 
{
    if (/^Cluster\s*[0-9]+/) 
      {
	my ($c,$elems) = split(/:/); 
	$c =~ s/^\s+//; 
	$c =~ s/\s+$//; 
	$elems =~ s/^\s+//; 
	$elems =~ s/\s+$//; 

	my %dhash = (); 
	my @files = split(/\s+/,$elems); 
	my $ffile = $files[0]; 

	$clusters{$c} = \@files; 
	my $lines = `cat $ffile`; 

	foreach $line (split(/\n/,$lines))
	  {
	    my $path = pathify($line); 
	    my $revpath = reverse_path($path); 

	    $path = $revpath if $path gt $revpath; 
	    $dhash{$path} = 1; 
	  }
	my @dkeys = keys(%dhash); 
	$dims{$c} = \@dkeys; 

	$blobs{$c} = $ffile if $#files == 0; 
      }
    else 
      {}
}

foreach $blob (keys(%blobs))
{
    my $min = 9387894726459873; # some biiig number 
    my $candidate = ""; 
    my $dimarr = $dims{$blob}; 

    foreach $cluster (keys(%dims))
    {
	unless ($blob eq $cluster)
	{
	    my $dist = diff($dimarr, $dims{$cluster}); 
	    $min = $dist if $min > $dist; 
	    $candidate = $cluster; 
	}
    }
    
    if ($candidate) 
    {
	my $carr = $clusters{$candidate}; 
	my $barr = $clusters{$blob}; 
	push @$carr, @$barr; 
	$clusters{$blob} = []; 
	$dims{$blob} = []; 
    }
}

open("outfile", ">clusters.tmp.$$"); 
foreach $cluster (keys(%clusters))
{
    my $list = $clusters{$cluster}; 
    print outfile "$cluster: " . join(" ", @$list) . "\n" if $#$list >= 0; 
}
close("outfile"); 

#system("./filter.pl clusters.tmp.$$"); 
#unlink "clusters.tmp.$$"; 

	
