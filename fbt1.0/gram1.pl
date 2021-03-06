#! /usr/bin/perl 

#
# gram.pl -- graph data miner 
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


sub reverse_path 
#
# reverse a path 
# 
{
    my $path = shift; 

    my @elems = split(/--/, $path); 
    my $rev_path = ""; 

    for ($i=$#elems; $i>=0; $i--) 
    {
	$rev_path .= $elems[$i]. "--" if $i > 0; 
	$rev_path .= $elems[$i] if $i == 0; 
    }

    return $rev_path; 
}

sub pathify
#
# convert a given path instance into a path type by stripping node ids 
#
{
    my $exp = shift; 

    $exp =~ s/\_[^\-]+//g; 
    $exp =~ s/\s+//g; 
    return $exp; 
}


sub count 
#
# count a given path and track the graphs that support the path 
#
{
    my $chash = shift; 
    my $phash = shift; 
    my $ghash = shift;    # Added graph tracking -- sri -- 23.04 
    my $cnd = shift; 

    my $pcnd = pathify($cnd); 
    my $prcnd = reverse_path($pcnd); 

#   print STDERR "pcnd = $pcnd,  prcnd = $prcnd\n"; 

    if (($pcnd cmp $prcnd) > 0) 
    {
	$pcnd = $prcnd; 
    }
    
    unless ($chash->{$pcnd}) 
    {
	$chash->{$pcnd} = 1; 
    }
    else 
    {
	$chash->{$pcnd} += 1; 
    }

    my $data = $phash->{$pcnd}; 
    $data .= "$cnd\n"; 

    $phash->{$pcnd} = $data; 

    if ($cnd =~ /^[^\_]+\_([^\_]+)\_/) 
    {
	my $gname = $1; 

	unless ($ghash->{$pcnd}) 
	{
	    $ghash->{$pcnd} = $gname; 
	}
	else 
	{
	    my $found = 0; 
	    my $oname; 
	    foreach $oname  (split(/,/,$ghash->{$pcnd})) 
	    {
		$found = 1 if $oname eq $gname; 
	    }
	    $ghash->{$pcnd} .= ",$gname" unless $found; 
	    print STDERR "$pcnd : $ghash->{$pcnd}\n"; 
	}
    }
	
#    print STDERR "cnd = $cnd; pcnd = $pcnd; phash{pcnd} = $phash->{$pcnd}\n"; 

    return ($chash, $phash, $ghash); 
}    

sub frequent
#
# given min_sup, chash and phash return a buffer comprising of frequent
# paths 
# 
{
    my $ms = shift; 
    my $chash = shift; 
    my $phash = shift; 
    my $count = 0; 
    my %shash = {}; 
    
    foreach $key (keys(%$chash))
    {
    #sudip....think that it should be increamented by 1,not by $chash->{$key}
	$count += $chash->{$key}; 
#	print STDERR "$key, $chash->{$key}, $count\n"; 
    }
    
    return ({}, {}) unless $count; 

    foreach $key (keys(%$chash)) 
    {
	if ($chash->{$key}/$count < $ms) 
	{
	    $phash->{$key} = ""; 
	    $shash{$key} = $chash->{$key}/$count; 
	}
    }

    return ($phash,\%shash); 
}    


sub oldalign 
#
# given two paths of length k, returns a path of length k+1 if possible 
# else returns 0 
# 
{
    my $path1 = shift; 
    my $path2 = shift; 

    my $done = 0; 

    $path1 =~ s/\s+//g; 
    $path2 =~ s/\s+//g; 

#    print STDERR "Aligning $path1 and $path2..."; 
    my @e1 = split(/--/, $path1); 
    my @e2 = split(/--/, $path2); 

    return 0 if $#e1 != $#e2; 

    my $k = $#e1+1; 

    my $i=1; $j=0; 

    while (! $done) 
    {
#	print STDERR "e1[$i] = $e1[$i]; e2[$j] = $e2[$j]..."; 
	if ($e1[$i] eq $e2[$j]) 
	{
	    $i ++; 
	    $j ++; 
	}
	else 
	{
#	    print STDERR "not possible..($i,$j)\n"; 
	    return 0; 
	}
	$done = 1 if $i >= $k; 
    }

    if ($done) 
    {
	$path1 .= "--" . $e2[$k-1]; 
#	print STDERR "Success! ($path1)\n"; 
	return $path1; 
    }
    else 
    {
#	print STDERR "not possible..\n"; 
	return 0; 
    }
}


sub align 
#
# new (hopefully faster) version of align 
#
{
    my $path1 = shift; 
    my $path2 = shift; 

    $path1 =~ s/\s+//g; 
    $path2 =~ s/\s+//g; 

    my $p1 = $path1; 
    my $p2 = $path2; 

    $p1 =~ s/^[^\-]+--//; 
    $p2 =~ s/(--[^\-]+)$//; 

    my $tail = $1; 

#    print STDERR "path1 = $path1; path2 = $path2; p1 = $p1; p2 = $p2; tail = $tail\n"; 
    return "$path1$tail" if $p1 eq $p2; 
#    print STDERR "no alignment possible...\n"; 
    return 0 unless $p1 eq $p2; 
}


sub nextgen 
#
# given a phash of paths of length k, generate candidate paths of length k+1
#
{
    my $phash = shift; 
    my $key1; 

    my @cndk1 = ();   # candidate k+1-paths 
    my %tkhash; 

    foreach $key1 (keys(%$phash))
    {
	my $key2; 
	foreach $key2 (keys(%$phash))
	{
#	    print STDERR "key1 = $key1; key2 = $key2\n"; 
	    if (align($key1, $key2) || align(reverse_path($key1),$key2) || align($key1,reverse_path($key2)))
	    {
		#sudip....what are the contents of tkhash? 
		unless ($tkhash{$key1}->{$key2})
		{
		    $tkhash{$key1}->{$key2} = 1; 
		    $tkhash{$key2}->{$key1} = 1; 

		    my @frk1 = (); 
		    my @frk2 = (); 
		    
		    push @frk1, split(/\n/, $phash->{$key1}); 
		    push @frk2, split(/\n/, $phash->{$key2}); 
		    
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
			    for ($j=0; $j<$numk2; $j++) 
			    {
#	    print STDERR "($i,$j) "; 
#			print STDERR "Checking $frk[$i], $frk[$j]\n"; 
				my $cnd = align($frk1[$i], $frk2[$j]);
				if ($cnd) 
				{
				    push @cndk1, $cnd;
#			    print STDERR "Found $cnd\n"; 
				}
				
				$cnd = align(reverse_path($frk1[$i]), $frk2[$j]); 
				if ($cnd) 
				{
				    push @cndk1, $cnd;
#			    print STDERR "Found $cnd\n"; 
				}
				
#			print STDERR "Checking $frk[$i], " . reverse_path($frk[$j]) . "\n"; 
				$cnd = align($frk1[$i], reverse_path($frk2[$j])); 
				if ($cnd) 
				{
				    push @cndk1, $cnd;
#			    print STDERR "Found $cnd\n"; 
				}
				
				$cnd = align($frk2[$j], $frk1[$i]);
				if ($cnd) 
				{
				    push @cndk1, $cnd;
#			    print STDERR "Found $cnd\n"; 
				}
				
				$cnd = align(reverse_path($frk2[$j]), $frk1[$i]); 
				if ($cnd) 
				{
				    push @cndk1, $cnd;
#			    print STDERR "Found $cnd\n"; 
				}
				
#			print STDERR "Checking $frk[$i], " . reverse_path($frk[$j]) . "\n"; 
				$cnd = align($frk2[$j], reverse_path($frk1[$i])); 
				if ($cnd) 
				{
				    push @cndk1, $cnd;
#			    print STDERR "Found $cnd\n"; 
				}
			    }
			}
		    }
		}
	    }
	}
    }

    print STDERR "\n"; 
    return @cndk1; 
}
#sudip....whats the function of this subroutine?
sub prune 
#
# prune all phash entries that are not supported by all graph names. use ghash
# for deciding 
# 
{
    my $phash = shift; 
    my $ghash = shift; 
    my $gnames = shift; 
    my @mgnames; 

    my $key;
    my $found; 

    foreach $key (keys(%$ghash))
    {
	$found = 1; 
	@mgnames = @$gnames; 
	my $suplist = $ghash->{$key}; 

	print STDERR "Checking: $key --> $suplist\n"; 

	do 
	{
	    $name = shift @mgnames; 
	    break unless $name; 
	    $found = 0; 
	    foreach $n (split(/,/,$suplist)) 
	    {
		$found = 1 if $name eq $n; 
	    }
	} while (found==1); 

	$phash->{$key} = "" if $found == 0; 
	print STDERR "Dropping $key ...\n" if $found == 0; 
    }
	    
    return ($phash, $ghash); 
}


#
# Main program 
#

require gram_init; 

if ($#ARGV == 0) 
{
    $ms = $ARGV[0];   # min. support provided on command line 
}

$files = `ls *.dot`; 
print "files is $files\n";
my %ch; 
my %ph; 
my %gh; 
#sudip....labeled path?is it same to selected paths?
$chash = \%ch;  # maintains a count for each labeled path 
$phash = \%ph;  # maintains a list of all occurrences of each labeled path 
$ghash = \%gh;  # maintains the list of all graph names in which each 
                # labeled path occurs
@gnames = (); 

foreach $file (split(/\s+/, $files))
{
    my $name = $file; 
    $name =~ s/\.dot.*$//; 
    $name =~ s/dm\-//g; 
    push @gnames, $name; 
    open (infile, "<$file") || break; 
    while (<infile>) 
    {
	s/\[type=.*$//g; 
	s/\s+//g; 
	s/\_([0-9]+)/\_$name\_$1/g; 
#	print STDERR "$_\n"; 
	#sudip....whats the use of this line?
	($chash, $phash, $ghash) = count($chash, $phash, $ghash, $_) if /--/; 
    }
    close (infile); 
}

my %sh; 
my $level=0; 
my $shash = \%sh; 

do {
    print STDERR "Starting mining at level $level\n"; 
    ($phash,$shash) = frequent($ms, $chash, $phash); 
    print STDERR "Starting pruning at level $level\n"; 
    ($phash, $ghash) = prune($phash, $ghash, \@gnames); 

    print "Level :$level\n"; 
    foreach $key (keys(%$phash))
    {
	print "INT:$level:$key:$shash->{$key}\n" if $phash->{$key} ne ""; 
	foreach $line (split(/\n/, $phash->{$key}))
	{
	    print "CND:$level:$line\n"; 
	}
	print "\n"; 
    }

#      foreach $key (keys(%$phash))
#      {
#  	foreach $line (split(/\n/, $phash->{$key}))
#  	{
#  	    print "CND:$level:$line\n"; 
#  	}
#      }

    {
	my @nextbuf = nextgen($phash); 
	$level ++; 
	%ch = {}; 
	%ph = {};
	%sh = {}; 
	%gh = {}; 
	$chash = \%ch; 
	$phash = \%ph; 
	$ghash = \%gh; 
	$shash = \%sh; 
	
	if ($level <= $maxlevels) 
	{
	    foreach $cnd (@nextbuf)
	    {
		print STDERR "counting $cnd\n"; 
		($chash, $phash, $ghash) = count($chash, $phash, $ghash, $cnd); 
	    }
	}
    }
}while ($level <= $maxlevels); 


