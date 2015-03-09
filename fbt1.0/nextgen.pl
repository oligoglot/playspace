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
# nextgen: given a substructure, generate all paths of next generation 
#

#
# WARNING: don't call this program with multiple .dot files!!
#

sub print_aligns 
#
{
    my $frk1 = shift; 
    my $frk2 = shift; 

    my $cnd = align($frk1, $frk2);
    if ($cnd) 
    {
	print "$cnd\n";
    }
    elsif($cnd = align(reverse_path($frk1), $frk2))
    {
	print "$cnd\n";
    }
    elsif($cnd = align($frk1, reverse_path($frk2))) 
    {
	print "$cnd\n";
    }
    elsif($cnd = align(reverse_path($frk1), reverse_path($frk2)))
    {
	print "$cnd\n";
    }
}


require gram_init; 

my %phash; 

# first segregate paths based on their labels 

while(<>) 
{
    unless (/^INT/) 
    {
	if (/--/) 
	{
	    s/^CND:[0-9]*://; 
	    s/\s+//g; 
	    
	    my $path = pathify($_); 
	    my $revpath = reverse_path($path); 
	    
	    $path = $revpath if $path gt $revpath; 
	    
	    $phash{$path} .= "$_\n"; 
	}
    }
}


my %tkhash; 

foreach $key1 (keys(%phash))
{
    my $key2; 
    foreach $key2 (keys(%phash))
    {
#	    print STDERR "key1 = $key1; key2 = $key2\n"; 
	if (align($key1, $key2) || align(reverse_path($key1),$key2) || align($key1,reverse_path($key2)) || align(reverse_path($key1), reverse_path($key2)))
	{
	    unless ($tkhash{$key1}->{$key2})
	    {
		$tkhash{$key1}->{$key2} = 1; 
		$tkhash{$key2}->{$key1} = 1; 
		
		my @frk1 = (); 
		my @frk2 = (); 
		
		push @frk1, split(/\n/, $phash{$key1}); 
		push @frk2, split(/\n/, $phash{$key2}); 
		
		my $numk1 = $#frk1 + 1; 
		my $numk2 = $#frk2 + 1; 
		
		if (($numk1) && ($numk2))
		{
		    my $i; 
		    
		    print STDERR "Aligning paths $key1 and $key2 ($numk1 paths against $numk2 paths to align):"; 
		    
		    for ($i=0; $i<$numk1; $i++) 
		    {	
			print STDERR "$i "; 
			my $j; 
			unless ($key1 eq $key2) 
			{
			    for ($j=0; $j<$numk2; $j++) 
			    {
				print_aligns($frk1[$i], $frk2[$j]) unless $frk1[$i] eq $frk2[$j]; 
			    }
			}
			else 
			{
			    for ($j=$i+1; $j<$numk2; $j++) 
			    {
				print_aligns($frk1[$i], $frk2[$j]) unless $frk1[$i] eq $frk2[$j]; 
			    }
			}
		    }
		}
		else  # if (($numk1) && ($numk2)) 
		{}
	    }
	}
    }
}

