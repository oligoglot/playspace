#!/usr/bin/perl

#
# Overall FBT algorithm 
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

my $typeof_file="";
my $loop=1;
my $iterate=27;
my $bck = 0;    # iteration number where to start bb filtering

my $totaledges = `$instdir/we.pl *.dot | grep Total`;
my $numgraphs = `ls *.dot | wc -w`; 
$numgraphs =~ s/\s+//g; 
$totaledges =~ s/^Total://g; 
my $avgsize = $totaledges/$numgraphs; 

chdir "$datadir"; 

open ("outfile", ">data.$$");
print outfile "ms = $ms\n"; 
print outfile "mc = $mc\n"; 
print outfile "numedges = $totaledges\n"; 
print outfile "numgraphs = $numgraphs\n"; 
print outfile "avgsize = $avgsize\n"; 
print outfile "bigblob = $bigblob\n"; 
print outfile "numiters = $iterate\n"; 
close("outfile"); 

open("outfile", ">data.st");
print outfile "numgraphs = $numgraphs\n"; 
close("outfile"); 

my $oldtime = time(); 
my $ctime = 0; 
my $outcount = 0; 

while($loop <= $iterate)
{
    $edges = 1; 
    $dedges = 1;
    system("$instdir/altgram.pl $typeof_file > gram.itm 2>err");
    $paths = `grep \"\\-\\-\" gram.itm | wc -l`;
    open ("outfile", ">>numpaths.dat.$$"); 
    print outfile "$loop $paths\n"; 
    close("outfile"); 
    system("mv gram.itm gram.tmp");

#    $itm_files = `ls *.*.itm`; 
#    foreach $file (split(/\s+/,$itm_files))
#    {
#	print STDERR "Moving $file ==> $file.$loop\n"; 
#	system("mv $file $file.$loop"); 
#    }

    system("rm *.itm");
    system("mv gram.tmp gram.itm");
    system("$instdir/all-segregate.pl gram.itm 0 2>err");
    $itm_files = `ls *.*.itm`; 
    unless ($itm_files) 
    {
	unlink "gram.itm"; 
	$loop --; 
	system("$instdir/cluster.pl *.*.itm.$loop > clusters$loop.st"); 
	$out_files = `ls *.out`; 
	if ($out_files) 
	{
		system("$instdir/cluster.pl threshold=0 *.out *.*.itm.$loop > output.total");
		system("rm clusters.tmp.*"); 
		system("$instdir/newbigblob.pl output.total"); 
#		system("mv clusters.tmp.* output.total"); 
#		system("$instdir/filter.pl clusters.tmp.* > edges.dat");
#		system("$instdir/rmbb.pl clusters.tmp.*"); 
		system("$instdir/cluster.pl threshold=0 *.out *.*.itm.$loop > output.total");
	}
	die("No more substructures found after $loop iterations..");
    }
    else 
    {
	my $oldloop = $loop - 1; 
	system("rm *.$oldloop"); 
    }
    system("rm gram.itm");

    $outputfile="clusters". $loop . ".st";
#    $itm_files = `ls *.*.itm`; 
    foreach $file (split(/\s+/,$itm_files))
    {
	print STDERR "Moving $file ==> $file.$loop\n"; 
	system("mv $file $file.$loop"); 
    }


#    system("$instdir/cluster.pl *.*.itm.$loop > $outputfile"); 
#    if (($bigblob eq "true") && ($loop >= $bck))
#    {
#	    system("rm clusters.tmp.*"); 
#	    system("$instdir/newbigblob.pl $outputfile"); 
#	    system("$instdir/filter.pl clusters.tmp.* > edges.dat");
#	    system("$instdir/rmbb.pl clusters.tmp.*"); 
#    }
#    else  
#    {
#	    system("$instdir/filter.pl $outputfile > edges.dat"); 
##	    system("$instdir/rmbb.pl $outputfile"); 
#    }
##    system("$instdir/cluster.pl *.*.itm.$loop > $outputfile"); 
#    system("rm clusters.tmp.*") if (($bigblob eq "true") && ($loop > $bck)); 
#    $edge_number=$loop+1;	


#    my $efile = `cat edges.dat`;
#    my $eline; 
#    foreach $eline(split(/\n/,$efile))
#    {
#	if ($eline =~ /^edges=/)
#	{
#	    $eline =~ s/^edges=//; 
#	    $eline =~ s/\s+//g; 
#	    $edges = $eline; 
#	}
#	elsif ($eline =~ /^dedges=/)
#	{
#	    $eline =~ s/^edges=//; 
#	    $eline =~ s/\s+//g; 
#	    $dedges = $eline; 
#	}
#    }
#    my $filt = ($dedges*100)/$edges; 
#    if ($filt > $dt*100)
#    {
#	print STDERR "edges = $edges\n"; 
#	print STDERR "dedges = $dedges\n"; 
#	die("Filtration threshold reached ($filt). Exiting..."); 
#    }
#    else
#    {
#	print STDERR "Filtration = $filt%\n"; 
#    }

    $allfiles = `echo *.*.itm.$loop`;
    $allines = "";  

    foreach $file (split(/\s+/,$allfiles))
    {
	my $we = `$instdir/we.pl $file`; 
        unless ($file =~ /^\s*$/) 
        {
	   if ($we <= $loop) 
	   {
		system("mv $file $file.out"); 
		print STDERR "$file => $file.out\n"; 
		$outcount ++; 
	   }
	}
    }


    my $rcount = 0; 
    unlink "next.itm";
    unless($loop==$iterate)
    {
	foreach $i (split(/\s+/,`ls *.*.itm.$loop`))
	{
	    print STDERR "Generating candidates for $i...\n"; 
#	    system("$instdir/newnextgen.pl ". $i ." >> next.itm 2>/dev/null");
#	    system("$instdir/dfsnextgen.pl ". $i ." >> next.itm 2>/dev/null");
	    unlink "numpaths.st"; 
	    system("$instdir/treenextgen.pl ". $i ." >> next.itm 2>numpaths.st");
	    my $status = `cat numpaths.st`; 
	    if ($status =~ /numpaths\s*=\s*([0-9]+)/) 
	    {
		my $numpaths = $1; 
		if ($numpaths <= 0) 
		{
			system("mv $i $i.out"); 
			print STDERR "$i produced no candidates. $i ==> $i.out\n"; 
			$outcount ++;
		}
	    }
#	    unlink $i; 
	    $rcount ++; 
	}
    }
    else 
    {
	$rcount = `ls *.*.itm.$loop | wc -w`;
    }
    
##    $typeof_file="*.*.itm";
    my $newtime = time();
    my $elapsed = $newtime - $oldtime; 
    $ctime += $elapsed; 

    open ("outfile", ">>time.$$"); 
    print outfile "$loop $elapsed\n";  
    close("outfile"); 
    $oldtime = $newtime; 

   open ("outfile", ">>ctime.$$"); 
   print outfile "$loop $ctime\n"; 
   close("outfile"); 

   my $strcount = $outcount + $rcount; 

   open ("outfile", ">>substructures.$$"); 
   print outfile "$loop $strcount\n"; 
   close("outfile"); 

    $typeof_file="next.itm";
    $loop++;
}

$loop --; 
system("$instdir/cluster.pl *.*.itm.$loop > $outputfile"); 
$itm_files = `ls *.out`; 
if ($itm_files) 
{
system("$instdir/cluster.pl threshold=0 *.out > output.total");
system("rm clusters.tmp.*"); 
system("$instdir/newbigblob.pl output.total"); 
#system("mv clusters.tmp.* output.total"); 
#system("$instdir/filter.pl clusters.tmp.* > edges.dat");
#system("$instdir/rmbb.pl clusters.tmp.*"); 
system("$instdir/cluster.pl threshold=0 *.out *.*.itm.$loop > output.total");
}
