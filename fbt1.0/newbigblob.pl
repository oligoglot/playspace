#!/usr/bin/perl -w 

#
# Remove big blobs 
# SYNOPSIS
#        newbigblob.pl clusterfile
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
%additions = (); 

sub issuperset
#
# is array ref 1 a super set of array ref 2 
#
{
	my $ref1 = shift; 
	my $ref2 = shift; 
	my $elem; 
	my %diffhash = (); 

	foreach $elem (@$ref2) 
	{
		$diffhash{$elem} = 1; 
	}

	my $answer = 1; 
	foreach $elem (@$ref1) 
	{
		$answer = 0 unless $diffhash{$elem}; 
	}
	
	return $answer; 
}

sub diff
#
# diff between 2 array refs 
#
  {
    my $ref1 = shift; 
    my $ref2 = shift; 
    my $elem; 
    my %diffhash = (); 

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

sub isblob
#
# Determines whether a cluster is a blob cluster 
#
{
	my $c = shift; 
	my $ng = shift; 
	my $size; 
	my $files = $clusters{$c}; 
	
	if ($mmode eq "C")
	{
		$size = countunique(@$files); 
	}
	else 
	{
		$size = $#$files + 1;
	}
	
	return 1 if $size/$ng < $ms; 

	return 0; 
}


#
# Main program 
#

my $cthreshold = 1; 
my $numgraphs = countgraphs(); 

die("Cannot determine number of graphs. ($numgraphs)\n") if $numgraphs <= 0;

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
	    my @alldims = split(/--/,$path);
	    for($i=0; $i<$#alldims; $i++)
	    {
		my $j = $i+1; 
		if ("$alldims[$i]:$alldims[$j]" le "$alldims[$j]:$alldims[$i]")	
		{
			$dhash{"$alldims[$i]:$alldims[$j]"} = 1; 
		}
		else 
		{
			$dhash{"$alldims[$j]:$alldims[$i]"} = 1; 
		} 
	    }
	  }
	my @dkeys = keys(%dhash); 
	$dims{$c} = \@dkeys; 

	$blobs{$c} = \@files if isblob($c,$numgraphs); 
      }
    else 
      {}
}

foreach $blob (keys(%blobs))
{
    if ($blobs{$blob}) 
    {
	    my $min = 9387894726459873; # some biiig number 
	    my $candidate = ""; 
	    my $dimarr = $dims{$blob}; 

	    foreach $cluster (keys(%dims))
	    {
	#	unless (($blob eq $cluster) || ($blobs{$cluster}))
		unless ($blob eq $cluster)
		{
	#	    if (issuperset($dimarr, $dims{$cluster}) || issuperset($dims{$cluster}, $dimarr))
		    if (issuperset($dimarr, $dims{$cluster}))
		    {
			    my $dist = diff($dimarr, $dims{$cluster}); 
			    $min = $dist if $min > $dist; 
			    $candidate = $cluster; 
		    }
		}
	    }
    
	    if ($candidate && $min <= 1) 
#	    if ($candidate) 
	    {
		print STDERR "Adding $blob to $candidate...\n"; 
		my $carr = $clusters{$candidate}; 
		my $barr = $clusters{$blob}; 
		push @$carr, @$barr; 

	#	my $carr = $additions{$candidate} if $additions{$candidate};
	#	$carr = [] unless $additions{$candidate}; 
	#	my $barr = $clusters{$blob}; 
	#	push @$carr, @$barr; 

		my %dhash = (); 
		my $clist = $dims{$candidate}; 
		foreach $dim (@$clist) 
		{
			$dhash{$dim} = 1; 
		}
		$clist = $dims{$blob}; 
		foreach $dim (@$clist) 
		{
			$dhash{$dim} = 1; 
		}
		my @dkeys = keys(%dhash); 
		$dims{$candidate} = \@dkeys; 
		$dims{$blob} = []; 
		$clusters{$blob} = []; 
		$blobs{$blob} = ""; 
	    }
	    else 
	    {
		
		print STDERR "No candidate cluster found for $blob or minimum distance was more than 1 ($min)...\n"; 
	    }
	}
}

#foreach $cluster (keys(%clusters))
#  {
#    my $carr = $clusters{$cluster}; 
#    my $barr = $additions{$cluster}; 
#
#    if ($#$barr >= 0) 
#      {
#	push @$carr, ("+"); 
#	push @$carr, @$barr; 
#      }
#  }

open("outfile", ">clusters.tmp.$$"); 
foreach $cluster (keys(%clusters))
{
    my $list = $clusters{$cluster}; 
    print outfile "$cluster: " . join(" ", @$list) . "\n" if $#$list >= 0; 
}
foreach $cluster (keys(%blobs))
{
	unless ($blobs{$cluster} eq "") 
	{
		my $blob = $blobs{$cluster}; 
		print outfile "$cluster: " . join(" ", @$blob) . "\n"; 
	}
}
close("outfile"); 

#system("./filter.pl tail=1 clusters.tmp.$$"); 
#unlink "clusters.tmp.$$"; 

	
