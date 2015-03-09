#! /usr/bin/perl -w

#
# cluster .itm files based on vectorization 
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


sub vectorize
#
# take a .dot file and vectorize (AnMol style) at level 0 
#
{
    my $data = shift; 
    my %vector; 
    my $line; 

    foreach $line (split(/\n/,$data))
    {
	$line =~ s/\s+//g; 

	my $pline = pathify($line); 
	my $prline = reverse_path($pline); 

	$pline = $prline if $pline gt $prline; 
	$pline =~ s/--/:/g; 

	$vector{$pline} += 1; 
	
#	$line =~ s/\b([^\_]+)\_[^\_]+\_[^\_-]+/$1/g; 
#	print STDERR "Vectorizing $line\n"; 
#	my @elems = split(/--/, $line); 

#	for ($i=0; $i<$#elems; $i++) 
#	{
#	    my $index = $elems[$i] . ":" . $elems[$i+1]; 
#	    $vector{$index} += 1; 
#	}
	
    }
	return \%vector; 
}


sub distance 
#
# vector distance 
#
{
    my $v1 = shift; 
    my $v2 = shift; 

    foreach $key (keys(%$v1))
    {
	unless ($v2->{$key}) 
	{
	    $v2->{$key} = 0; 
	}
    }

    foreach $key (keys(%$v2))
    {
	unless ($v1->{$key}) 
	{
	    $v1->{$key} = 0; 
	}
    }

    my $dist = 0; 

    foreach $key (keys(%$v1))
    {
	$dist += ($v1->{$key} - $v2->{$key})*($v1->{$key} - $v2->{$key}); 
    }

    $dist = sqrt($dist); 

    return $dist; 
}


#
# main program 
#

require gram_init; 
my $data; 
my %filehash; 
my %dimhash = (); 

foreach $file (@ARGV) 
{
    $data = ""; 

    open("infile", "<$file"); 
    while (<infile>) 
    {
	s/^CND:[^:]*://; 
	$data .= $_; 
    }
    close("infile"); 

    my $vector = vectorize($data); 
    $filehash{$file} = $vector; 

    print STDERR "Vector for $file...\n"; 
    foreach $key (keys(%$vector)) 
    {
	print STDERR "$key => $vector->{$key}\n"; 
    }
}

my @bucket; 
my $nb = 0; 

foreach $file (keys(%filehash))
{
    my $min = 2789452389756872894; # some big number 
    my $candidate = -1; 

    for ($i=0; $i<$nb; $i++) 
    {
	foreach $ofile (split(/\s+/, $bucket[$i]))
	{
	    my $v1 = $filehash{$file}; 
	    my $v2 = $filehash{$ofile}; 
 
	    my $d = distance($v1, $v2); 

	    if ($d < $min) 
	    {
		$min = $d; 
		$candidate = $i; 
	    }
	}
    }

    if ($min <= $threshold) 
    {
	$bucket[$candidate] .= " $file"; 
	print STDERR "$file ==> bucket $candidate\n";
	my $vector = $filehash{$file}; 
	foreach $dims (keys(%$vector))
	{
		$dimhash{$dims} .= "$candidate " unless $dimhash{$dims} =~ /\b$candidate\b/; 
	}
    }
    else 
    {
	$bucket[$nb] = "$file"; 
	my $vector = $filehash{$file}; 
	foreach $dims (keys(%$vector))
	{
		$dimhash{$dims} .= "$nb "; 
	}
	$nb++; 
	print STDERR "New bucket $nb for $file\n"; 
    }
}

my @bitmap = (); 
my @dimarray = sort(keys(%dimhash)); 
print STDERR @dimarray; 

for ($i=0; $i<=$#bucket; $i++)
{
	my $bm = 0; 
	for ($j=0; $j<=$#dimarray; $j++) 
	{
#		print STDERR "$dimarray[$j] is held by $dimhash{$dimarray[$j]}\n"; 
#		<STDIN>;
		if ($dimhash{$dimarray[$j]} =~ /\b$i\b/) 
		{
			$bm = ($bm << 1) | 1; 
		}
		else 
		{
			$bm <<= 1; 
		}
	}
	$bitmap[$i] = $bm; 
}

for ($i=0; $i<$#bitmap; $i++)
{
	for ($j=$i+1; $j<=$#bitmap; $j++) 
	{
		unless ($bitmap[$j] == 0)
		{
			my $and = $i & $j; 
			if ($and == $i || $and == $j)
			{
				print STDERR "Merging clusters $i and $j...\n";
				$bucket[$i] .= " $bucket[$j]"; 
				$bucket[$j] = ""; 
				$bitmap[$j] = 0; 
			}
		}
	}
}

my $i = 0; 
foreach $cluster (@bucket)
{
    print "Cluster $i: $cluster\n" unless $cluster eq ""; 
    $i ++; 
}

