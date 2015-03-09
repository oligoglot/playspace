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


#
# nextgen: given a substructure, generate all possible paths of next 
# generation 
#
# Usage newnextgen.pl <candidatefilename> <.itm file>
#
# ..where next generation paths are merged into paths already present
# in candidate file name. 
# 

require gram_init; 


my @tpaths; 
my %edgehash = (); 

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
	push @tpaths, ($line); 
	my @nodes = split(/--/,$line); 
	my $i; 

	for ($i=0; $i<$#nodes; $i++) 
	{
	    my $j = $i+1; 
	    $ghash{$nodes[$i]} .= "$nodes[$j] "; 
#	    print STDERR "ghash{$nodes[$i]} = $ghash{$nodes[$i]}\n"; 
	    $ghash{$nodes[$j]} .= "$nodes[$i] "; 
#	    print STDERR "ghash{$nodes[$j]} = $ghash{$nodes[$j]}\n"; 
	}

#	my $rline = reverse_path($line); 
#	$line = $rline if $line gt $rline; 
	
#       my $path = pathify($line); 
#  	my $rpath = reverse_path($path); 

#  	$path = $rpath if $path gt $rpath; 

#  	$thash{$path} += 1; 
#  	foreach $node (split(/--/,$path))
#  	{
#  	    $ahash{$node} += 1; 
#  	}
    }
}

my $npathcount = 0; 
my %nhash = (); 
foreach $path (@tpaths)
{
    foreach $a (keys(%ghash))
    {
#      print STDERR "Checking $a against $path\n"; 
	my $i;
	my $j; 
	my @tarr = split(/--/,$path); 
	for ($i=0; $i<=$#tarr+1; $i++) 
	{
	    my $iset = "NIL";
	    $npathcount ++; 

	    my @parr = split(/--/, $path);
	    my $newpath; 
	    my @nparr = (); 
	    my $e; 
	    for ($j=0; $j<$i; $j++) 
	    {
		$e = shift @parr; 
		push @nparr, ($e); 
	    }
	    if ($#nparr >= 0) 
	    {
		$e = $nparr[$#nparr]; 
	    }
	    else 
	    {
		$e = $parr[0]; 
	    }
	    my $pred1; 
	    $pred1 = 1 if $ghash{$e} =~ /\b$a\b/; 
	    if ($#nparr < $#tarr) 
	    {
		$e = $parr[0]; 
	    }
	    else 
	    {
		$e = $nparr[$#nparr]; 
	    }
	    my $pred2;
	    $pred2 = 1 if $ghash{$e} =~ /\b$a\b/; 
#	    print STDERR "e = $e, ghash{e} = $ghash{$e}\n"; 
	    if ($pred1 && $pred2)
	    {
		push @nparr, ($a); 
		push @nparr, @parr; 

		my $rset; 
		my $n; 
		my $i; 

# Check to see that there are no duplicate edges in the new path 
# Also check to see if the path is redundant 
#		print STDERR "Processing " . join ("--",@nparr) . "\n";
		
		for ($i=0; $i<$#nparr; $i++) 
		  {
		    my $j; 
		    my $key;

		    $j = $i+1; 
		    if ($nparr[$i] le $nparr[$j]) 
		      {
			$key = "$nparr[$i]:$nparr[$j]"; 
		      }
		    else 
		      {
			$key = "$nparr[$j]:$nparr[$i]"; 
		      }

		    if ($nhash{$key}) 
		    {
			$rset = $nhash{$key}; 
		    } 
		    else 
		    {
			    $rset = ""; 
		    }

		    if ($iset eq "NIL")
		    {
				$iset = $rset;
		    }
	   	    else 
		    {
			foreach $cnd (split(/\s+/,$iset))
			{
				unless ($rset =~ /\b$cnd\b/) 
				{
					$iset =~ s/\s*$cnd\s+/ /g; 
				} 
			}
		    }

		  }

		my $redundant = 0;
		$redundant = 1 unless ($iset =~ /^\s*$/i || $iset eq "NIL"); 

#		print STDERR join("--",@nparr) . "is a redundant path ($iset)\n" if $redundant;

		my %rhash = (); 
		my $indx; 
		for($indx=0; $indx<$#nparr; $indx++)
		{
			my $j = $indx+1; 
			$rhash{"$nparr[$indx]:$nparr[$j]"} = 0 unless $rhash{"$nparr[$indx]:$nparr[$j]"}; 
			$rhash{"$nparr[$indx]:$nparr[$j]"} += 1; 
			$rhash{"$nparr[$j]:$nparr[$indx]"} = 0 unless $rhash{"$nparr[$j]:$nparr[$indx]"}; 
			$rhash{"$nparr[$j]:$nparr[$indx]"} += 1; 
		}
		
		my $fine = 1; 
		foreach $n (keys(%rhash)) 
		{
#		    print STDERR "$n, $rhash{$n}\n"; 
		    $fine = 0 if $rhash{$n} > 1; 
		}

#		if ($fine == 0) 
#		{
#		    print STDERR join("--",@nparr) . " has a cycle\n"; 
#		    for ($i=0;$i<$#nparr;$i++)
#		    {
#			my $j = $i+1; 
#			my $key; 
#			if ($nparr[$i] le $nparr[$j]) 
#			{
#			    $key = "$nparr[$i]:$nparr[$j]"; 
#			}
#			else 
#			{
#			    $key = "$nparr[$j]:$nparr[$i]"; 
#			}
#			$edgehash{$key} -= 1; 
#			print STDERR "$key is reset.\n" if $edgehash{$key} == 0; 
#		    }
#		}

		if (($fine==1) && ($redundant == 0)) 
#		if ($fine) 
		{
		    my $i; 
		    for ($i=0; $i<$#nparr; $i++) 
		    {
			my $j = $i + 1; 
			$nhash{"$nparr[$i]:$nparr[$j]"} .= "$npathcount "; 
			$nhash{"$nparr[$j]:$nparr[$i]"} .= "$npathcount "; 
		    }
		    $newpath = join("--", @nparr); 
		    $rnewpath = reverse_path($newpath); 
		    $newpath = $rnewpath if $newpath gt $rnewpath; 
		    $chash{$newpath} += 1;
		}
		else 
		{
#		    $newpath = join("--", @nparr); 
#		    print STDERR "Rejecting $newpath\n"; 
		}
	    }
#	    print STDERR "i: $i; Path: $path; New path: $newpath\n"; 
	}
    }
}

#open ("outfile", ">$cfname"); 
#print outfile "\%chash = (\n"; 
foreach $newpath (keys(%chash))
{
#    print outfile "\"$newpath\" => $chash{$newpath},\n"; 
    print "$newpath\n"; 
}
#print outfile ");\n"; 
#close("outfile"); 

