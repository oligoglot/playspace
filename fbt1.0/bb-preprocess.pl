#!/usr/bin/perl -w 

#
# proximity.pl -- generate a graph of atomic proximity from a pdb file 
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


sub distance
#
# calculate distances betwee two points in 3D space 
# 
{
    my $a = shift; 
    my $b = shift; 

    my $dist = sqrt(($a->{"x"}-$b->{"x"})*($a->{"x"}-$b->{"x"}) + 
		    ($a->{"y"}-$b->{"y"})*($a->{"y"}-$b->{"y"}) +
		    ($a->{"z"}-$b->{"z"})*($a->{"z"}-$b->{"z"})); 
    return $dist; 
}

### main program 

$cutoff = 5;   # angstroms 
#$covalent = 1.65; #covalent bond length 
# %space = {}; 

print "graph somename {\n"; 

while(<>) 
{
    if (/^ATOM/)
    {
	($tmp, $tmp, $name, $amino, $num, $x, $y, $z) = split(/\s+/); 
	unless ($num =~ /^[0-9]+$/) 
	{
		($tmp, $tmp, $name, $amino, $tmp, $num, $x, $y, $z) = split(/\s+/); 
	}

	if (($name eq "CA") || ($name eq "N") || ($name eq "C"))
	#if ($name eq "CA")
	{
	    $xo = int(($x + 200 + 0.5)/$cutoff); 
	    $yo = int(($y + 200 + 0.5)/$cutoff); 
	    $zo = int(($z + 200 + 0.5)/$cutoff);

	    my $point = {}; 
	    
	    $point->{"name"} = "$name" . "_" . "$num"; 
	    $point->{"x"} = $x; 
	    $point->{"y"} = $y; 
	    $point->{"z"} = $z; 
	    
	    $space{"$xo:$yo:$zo"} = () unless $space{"$xo:$yo:$zo"}; 
	    $bucket = $space{"$xo:$yo:$zo"}; 

#  	    $xh{$xo} += 1; 
#  	    $yh{$yo} += 1; 
#  	    $zh{$zo} += 1; 

#	    print STDERR "$point->{name}: ($x,$y,$z) => space[$xo][$yo][$zo]\n"; 
	    push(@$bucket,$point); 
	    $space{"$xo:$yo:$zo"} = $bucket; 
	}
    }
}

foreach $coord (keys(%space))
{

    my ($xk,$yk,$zk) = split(/:/, $coord); 
#    print STDERR "coord = ($xk,$yk,$zk)\n"; 

    my $bucket = $space{$coord}; 
    my @arr = @$bucket; 

#    for ($i=0; $i<$#arr; $i++) 
#    {
#	for ($j = $i+1; $j<$#arr; $j++) 
#	{
#	    print "$arr[$i]->{name}--$arr[$j]->{name}[type=n];\n"; 
#	}
#    }

    my @coordarr;
    
    push (@coordarr, join(":", $xk-1,$yk,$zk)); 
    push (@coordarr, join(":", $xk+1,$yk,$zk)); 
    push (@coordarr, join(":", $xk,$yk-1,$zk)); 
    push (@coordarr, join(":", $xk,$yk+1,$zk)); 
    push (@coordarr, join(":", $xk,$yk,$zk-1)); 
    push (@coordarr, join(":", $xk,$yk,$zk+1)); 

    push (@coordarr, join(":", $xk-1,$yk-1,$zk)); 
    push (@coordarr, join(":", $xk-1,$yk-1,$zk-1)); 
    push (@coordarr, join(":", $xk-1,$yk-1,$zk+1));
    push (@coordarr, join(":", $xk-1,$yk+1,$zk)); 
    push (@coordarr, join(":", $xk-1,$yk+1,$zk-1)); 
    push (@coordarr, join(":", $xk-1,$yk+1,$zk+1));
    push (@coordarr, join(":", $xk-1,$yk,$zk-1)); 
    push (@coordarr, join(":", $xk-1,$yk-1,$zk-1)); 
    push (@coordarr, join(":", $xk-1,$yk+1,$zk-1));
    push (@coordarr, join(":", $xk-1,$yk,$zk+1)); 
    push (@coordarr, join(":", $xk-1,$yk-1,$zk+1)); 
    push (@coordarr, join(":", $xk-1,$yk+1,$zk+1));

    push (@coordarr, join(":", $xk+1,$yk-1,$zk)); 
    push (@coordarr, join(":", $xk+1,$yk-1,$zk-1)); 
    push (@coordarr, join(":", $xk+1,$yk-1,$zk+1));
    push (@coordarr, join(":", $xk+1,$yk+1,$zk)); 
    push (@coordarr, join(":", $xk+1,$yk+1,$zk-1)); 
    push (@coordarr, join(":", $xk+1,$yk+1,$zk+1));
    push (@coordarr, join(":", $xk+1,$yk,$zk-1)); 
    push (@coordarr, join(":", $xk+1,$yk-1,$zk-1)); 
    push (@coordarr, join(":", $xk+1,$yk+1,$zk-1));
    push (@coordarr, join(":", $xk+1,$yk,$zk+1)); 
    push (@coordarr, join(":", $xk+1,$yk-1,$zk+1)); 
    push (@coordarr, join(":", $xk+1,$yk+1,$zk+1));
     
    foreach $next (@coordarr) 
    {
#	print STDERR "Searching: $next\n"; 
	if ($space{$next})
	{
#	    print STDERR "Found a neighbour...\n"; 
	    $b1 = $space{$coord}; 
	    $b2 = $space{$next}; 

	    foreach $m1 (@$b1) 
	    {
		foreach $m2 (@$b2)
		{
#		    print STDERR "Comparing $m1->{name} and $m2->{name}\n";  
		    my $n1 = $m1->{"name"}; 
		    my $n2 = $m2->{"name"}; 
		    my $okay = 0; 

		    if ($n1 lt $n2) 
		    {
			$okay = 1 unless $check{"$n1--$n2"}; 
		    } 
		    elsif ($n1 eq $n2) 
		    { 
			$okay = 0; 
		    }
		    else 
		    {
			$okay = 1 unless $check{"$n2--$n1"}; 
		    }
			
		    if ($okay) 
		    { 
			    my $d = distance($m1, $m2); 
			    #if (($d > $covalent) && ($d <= $cutoff))
			    if ($d <= $cutoff)
			    {
				print "$m1->{name}--$m2->{name}"."[type=n];\n"; 
			    }
			    if ($n1 lt $n2) 
			    {
				$check{"$n1--$n2"} = 1; 
			    } 
			    else 
			    { 
				$check{"$n2--$n1"} = 1; 
			    }
		     }
		}
	    }
	}
    }
}

print "}\n"; 
