#!/usr/bin/perl -w

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
	die ("Usage: all-segregate.pl <itm_file> <level>\n"); 
}

# $fprefix = $ARGV[0]; 
# $fprefix =~ s/\.itm\s*$//; 

my %numc; 

$level = $ARGV[1]; 
$level =~ s/\s+//g; 

my %cluster; 

open("infile", "<$ARGV[0]") || die "Cannot open $ARGV[0]. $!\n"; 

while(<infile>) 
{
    if (/^CND:$level:/)
    {
	s/\n//; 
	s/\s+$//; 
	my $line = $_; 
	($tmp,$tmp,$rec,@temp) = split(/:/, $line); 
	$line = "$rec\n";
	my $found = -1; 
	my @elems = split(/--/, $rec); 

	my $firstelem = $elems[0]; 
	$firstelem =~ /^[^\_]+\_([^\_]+)\_[^\_]+/; 
	my $name = $1; 
	my $bucketlist; 
	my $size = 0; 

	if ($cluster{$name}) 
	{
	    $bucketlist = $cluster{$name}; 
	    $size = $#$bucketlist + 1; 
	}
	else 
	{
	    $cluster{$name} = []; 
	    $bucketlist = $cluster{$name}; 
	    $size = $#$bucketlist + 1; 
	}

	foreach $elem (@elems)
	{
	    for ($i=0; $i<$size; $i++) 
	    {
		if ($bucketlist->[$i] =~ /\b$elem\b/) 
		{
		    if ($found == -1) 
		    {
			$found = $i; 
			$bucketlist->[$i] .= $line; 
			print STDERR "Adding to cluster number $i of $name: $line\n"; 
		    }
		    elsif ($found != $i)
		    {
			$bucketlist->[$i] .= $bucketlist->[$found]; 
			$bucketlist->[$found] = ""; 
			print STDERR "Merging cluster number $i with cluster number $found of $name:\n $bucketlist->[$i]\n";  
			$found = $i; 
		    }
		}
		else 
		{}
	    }
	}

	if ($found == -1) 
	{
	    $bucketlist->[$size] = $line; 
	    $found = $size; 
	    print STDERR "Creating new cluster ($size) under $name for $line\n"; 
	    $size ++; 
	}

#  	foreach $elem (@elems)
#  	{
#  	    for ($j=0; $j<$size; $j++) 
#  	    {
#  		unless ($j == $found) 
#  		{
#  		    if ($bucketlist->[$j] =~ /\b$elem\b/) 
#  		    {
#  			print STDERR "Merging cluster $found with cluster $i of $name...\n"; 
#  			$bucketlist->[$found] .= $bucketlist->[$j]; 
#  			$bucketlist->[$j] = ""; 
#  		    }
#  		}
#  	    }
#  	}

	
	# remove duplicate paths 
#  	for ($j=0; $j<$size; $j++) 
#  	{
#  	    my $dhash = {}; 
#  	    foreach $entry (split(/\n/, $bucketlist->[$j]))
#  	    {
#  		$entry =~ s/\s+//g; 
#  		$dhash->{$entry} += 1; 
#  	    }
#  	    $entry = join("\n", keys(%$dhash)); 
#  	    $bucketlist->[$j] = "$entry\n"; 
#  	}

#  	foreach $elem (@elems)
#  	{
#  	    $elem =~ /^[^\_]+\_([^\_]+)\_[^\_]+/; 
#  	    my $name = $1; 

#  	    my $bucketlist = $cluster{$name}; 
	    

#  	    unless ($found) 
#  	    {
#  		my $i; 
#  		$numc{$name} = 0 unless $numc{$name}; # num clusters
#  		for ($i=0; $i<$numc{$name} && (!$found); $i++) 
#  		{
#  		    unless ($found) 
#  		    {
#  			if ($cluster{$name}->[$i] =~ /\b$elem\b/)
#  			{
#  			    my $myc = $cluster{$name}->[$i]; 
#  			    $found = 1; 
#  			    $cluster{$name}->[$i] .= $line; 
#  			    foreach $oelem (@elems)
#  			    {
#  				unless ($oelem eq $elem)
#  				{
#  				    for($j=0; $j<$numc{$name}; $j++) 
#  				    {
#  					unless ($j == $i) 
#  					{
#  					    if($cluster{$name}->[$j] =~/\b$oelem\b/)
#  					    {
#  						$cluster{$name}->[$i] .= $cluster{$name}->[$j]; 
#  						$cluster{$name}->[$j] = ""; 
#  					    }
#  					}
#  				    }
#  				}
#  			    }
#  			}
#  		    }
#  		}
#  	    }
#  	}
	
#  	unless ($found) 
#  	{
#  	    ($tmp,$tmp,$rec) = split(/:/,$line); 
#  	    $rec =~ /^[^\_]+\_([^\_]+)\_[^\_]+/; 
#  	    my $name = $1; 
	    
#  	    $numc{$name} = 0 unless $numc{$name}; 
#  	    $cluster{$name}->[$numc{$name}] = $line; 
#  	    $numc{$name} += 1; 
#	}
    }
} 

close ("infile"); 

foreach $name (keys(%cluster)) 
{
    my $bucketlist = $cluster{$name}; 
    my $numc; 

    print "Processing clusters for $name:\n"; 
#    print "Number of substructures for $name: $numc{$name}\n"; 

    $numc = 0; 
    for ($i=0; $i<=$#$bucketlist; $i++) 
    {
	unless ($bucketlist->[$i] =~ /^\s*$/) 
	{
	    $numc ++;
	    print "Writing $name.$i.itm...\n"; 
#	    print STDERR $bucketlist->[$i]; 
	    open ("outfile", ">$name.$i.itm") || die "Cannot open $name.$i.itm. $!\n"; 
	    print outfile "$bucketlist->[$i]"; 
	    close ("outfile"); 
	}
    } 
     print "Number of substructures for $name: $numc\n"; 
}						


