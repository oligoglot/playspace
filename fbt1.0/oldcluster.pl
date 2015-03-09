#! /usr/bin/perl -w

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

#
# cluster .itm files based on vectorization 
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
my %chunkhash; 
my %buckethash; 
my %chunkptr; 

sub chunkify 
#
# chunk a vector 
#
{
	my $point = shift; 
	my $name = shift; 
	my $dim; 
	my $proj; 
	my $cth = 5 + $threshold; 

	foreach $dim (keys(%$point))
	{
		$proj = $point->{$dim}; 
		my $chunk = int($proj / $cth); 
#		print STDERR ">>>>>$name, $dim, $chunk\n"; 
		$chunkhash{$dim}->{$chunk} .= "$name "; 
		$chunkptr{$name}->{$dim} = $chunk; 
	}
}

if ($ARGV[0] =~ /=/)
{
	my $param = shift; 
	$param =~ /threshold=([0-9\.]+)/; 
	$threshold = $1; 
}

print STDERR "threshold=$threshold\n"; 
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

    my $vector = $filehash{$file}; 
    my $searchspace = ""; 

    chunkify($vector, $file); 
    foreach $dim (keys(%$vector))
    {
	my $chunk = $chunkptr{$file}->{$dim}; 
	print STDERR "$file is in $chunk chunk in $dim dimension...\n";
	$searchspace .= " $chunkhash{$dim}->{$chunk}"; 
	$searchspace .= $chunkhash{$dim}->{$chunk-1} if $chunkhash{$dim}->{$chunk-1} && $threshold > 0; 
	$searchspace .= $chunkhash{$dim}->{$chunk+1} if $chunkhash{$dim}->{$chunk+1} && $threshold > 0; 
	print STDERR "$dim :::::::: $searchspace :::::::  $file\n"; 
    }
 
    my %checked = ();    
    foreach $ofile (split(/\s+/, $searchspace))
    {
	unless ($file eq $ofile || $checked{$ofile})
	{
		my $bnum = $buckethash{$ofile} if $buckethash{$ofile}; 
		$bnum =~ s/\s+//g if $bnum; 

		my $v1 = $filehash{$file}; 
		my $v2 = $filehash{$ofile}; 
		my $d = distance($v1, $v2); 
		
	#	print STDERR "Distance between $file, $ofile = $d\n";	    
		if ($d < $min) 
		{
			$min = $d; 
			$candidate = $bnum if $buckethash{$ofile}; 
	#		print STDERR "Candidate bucket for $file is $candidate. (ofile = $ofile)\n";
		}
		$checked{$ofile} = 1; 
	}
    }

    print STDERR "min = $min, threshold = $threshold, candidate = $candidate\n";
    if ($min <= $threshold && $candidate != -1) 
    {
	$bucket[$candidate] .= " $file"; 
	print STDERR "$file ==> bucket $candidate\n";
	$buckethash{$file} = "$candidate "; 
    }
    else 
    {
	$bucket[$nb] = "$file"; 
	$buckethash{$file} = "$nb "; 
	$nb++; 
	print STDERR "New bucket $nb for $file\n"; 
    }
}

for ($i=0; $i<$nb; $i++) 
{
    print "Cluster $i: $bucket[$i]\n"; 
}

