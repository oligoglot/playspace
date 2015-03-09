
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

# installation directory for code 
$instdir = "."; 

# directory where data is present 
$datadir = "."; 

# min support 
$ms = 0.07;

# max levels 
$maxlevels = 0; 

# big blob filtering switch (change to "true" to enable bigblob filtering)
$bigblob = "true"; 

# threshold for clustering 
$threshold = 0; 

# min support for cluster filtering 
$mc = 1;

# mmode = "F" for frequency mining, "C" for common structure mining, 
# "FC" for both frequency and common structure mining 
$mmode = "C"; 

# threshold for stopping iterations 
$dt = 0.1; 

# number of edges and dropped edges. When dedges/edges < dt iteration stops
$edges = 1; 
$dedges = 1;

sub reverse_path 
#
# reverse a path 
# 
{
    my $path = shift; 

    my @elems = split(/--/, $path); 
    my $rev_path = ""; 
    my $i; 

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


sub countgraphs
#
# Count the number of graphs whose answer is stored in data.st 
#
{
	my $ng = -1; 
	open("infile", "<data.st") || return $!;
	while(<infile>)
	{
		print STDERR "$_"; 
		chop;
		if (/numgraphs\s*=\s*([0-9]+)$/)
		{
			$ng = $1; 
		}
	}
	close("infile"); 

	$numgraphs = $ng; 
	return $ng; 
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

    my %p1hash;
    my %p2hash;

    if ($path1 =~ /^[^_]+\_/)  # return if paths contain a cycle 
    {
	foreach $node (split(/--/,$path1))
	{
	    $p1hash{$node} += 1; 
	}
	
	foreach $node (keys(%p1hash))
	{
	    if ($p1hash{$node} > 1)
	    {
		print STDERR "Because of p1hash{$node} = $p1hash{$node} I am Rejecting path: $path1\n"; 
		return 0;
	    }
	}

	foreach $node (split(/--/,$path2))
	{
	    $p2hash{$node} += 1; 
	}
	
	foreach $node (keys(%p2hash))
	{
	    if ($p2hash{$node} > 1) 
	    {
		print STDERR "Rejecting path: $path2\n"; 
		return 0; 
	    }
	}
    }

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
