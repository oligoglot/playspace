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
	    my $revpath = reverse_path($path); 

	    $path = $revpath if $path gt $revpath; 
	    $dhash{$path} = 1; 
	  }
	my @dkeys = keys(%dhash); 
	$dims{$c} = \@dkeys; 

	$blobs{$c} = \@files if isblob($c,$numgraphs); 
#	print STDERR "$c is a big blog cluster...\n"; 
      }
    else 
      {}
}

foreach $blob (keys(%blobs))
{
    my $candidate = ""; 
    my $dimarr = $dims{$blob}; 
    my @candidates = (); 

    foreach $cluster (keys(%dims))
    {
#	unless (($blob eq $cluster) || ($blobs{$cluster}))
	unless ($blob eq $cluster)
	{
#	    if (issuperset($dimarr, $dims{$cluster}) || issuperset($dims{$cluster}, $dimarr))
	    if (issuperset($dimarr, $dims{$cluster}))
	    {
		push @candidates, $cluster; 
	    }
	}
    }

    my $i = 0; 
    foreach $candidate (@candidates) 
    {
	print STDERR "Adding $blob to $candidate...\n"; 
	my $files = $clusters{$blob}; 
	foreach $file (@$files) 
	{
		if ($file =~ /^[^\.]+\.[0-9]+\.itm/) 
		{
			my $oldfile = $file; 
			$file =~ s/^([^\.]+)\.([0-9]+)\.itm/$1.$2.$i.itm/g; 
			system("cp $oldfile $file"); 
			print STDERR "Copying $oldfile to $file...\n"; 
		}
		elsif ($file =~ /^[^\.]+\.[0-9]+\.[0-9]+\.itm/) 
		{
			my $oldfile = $file; 
			$oldfile =~ s/^([^\.]+)\.([0-9]+)\.[0-9]+\.itm(.*)/$1.$2.itm$3/g; 
			$file =~ s/^([^\.]+)\.([0-9]*)\.[0-9]*\.itm/$1.$2.$i.itm/g; 
			system("cp $oldfile $file"); 
			print STDERR "Copying $oldfile to $file...\n"; 
		}
		else 
		{
			print STDERR "Ignoring $file..."; 
		}
		my $carr = $clusters{$candidate}; 
		push @$carr, @$files; 
	}
	$i ++;
    }
    $clusters{$blob} = []; 
    $dims{$blob} = []; 
    $blobs{$blob} = "";
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
		print outfile "$cluster: $blob\n"; 
	}
}
close("outfile"); 

#system("./filter.pl tail=1 clusters.tmp.$$"); 
#unlink "clusters.tmp.$$"; 

	
