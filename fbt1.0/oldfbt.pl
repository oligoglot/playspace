#!/usr/bin/perl

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


my $typeof_file="";
my $loop=1;
my $iterate=9;
while($loop!=$iterate)
	{
	system("./altgram.pl ". $typeof_file .">gram.itm 2>err");
	$paths = `grep \"\\-\\-\" gram.itm | wc -l`;
	open ("outfile", ">>numpaths.dat.$$"); 
	print outfile "$loop $paths\n"; 
	close("outfile"); 
	system("mv gram.itm gram.tmp");
	system("rm *.itm");
	system("mv gram.tmp gram.itm");
	system("./all-segregate.pl gram.itm 0 2>err");
	$itm_files = `ls *.*.itm`; 
	unless ($itm_files) 
	{
		die("No more substructures found after $loop iterations..");
	}
	system("rm gram.itm");
	$outputfile="clusters". $loop . ".st";
	system("./cluster.pl *.*.itm > $outputfile"); 
	system("./filter.pl $outputfile ");
        $edge_number=$loop+1;	
	$allines = `./we.pl *.*.itm`; 
	print STDERR "$allines\n"; 
	@lines = split(/\s+/, $allines); 
	foreach $line (@lines) 
	{
		if ($line =~ /^\s*[0-9]+/) 
		{
			my ($we, $file) = split(/:/, $line); 
			if ($we <= $loop) 
			{
				system("mv $file $file$loop"); 
				print STDERR "$file => $file$loop\n"; 
			}
		}
	}
	system("./cluster.pl *.*.itm$loop > $outputfile");
#	system("./part2.pl " . $outputfile . " " . $edge_number);  	
	unless($loop==$iterate-1)
		{
		foreach $i (split(/\s+/,`ls *.*.itm`))
			{
			system("./nextgen.pl ". $i ." > tmp");
	 		system("mv tmp ".$i);
 			}
		}
	
	$typeof_file="*.itm";
	$loop++;
	}
	#open(file ,"<./clusters.st");
	#$count=0;
	#while(<file>)
	#	{
	#	$line[$count++]=$_;
	#	}	
	#print "finished\n";



	

	
#}
#$choice=<stdin>;
#$choice=~ s/\s*\r*\n//g;
#$i=0;
#$line[$choice]=~ s/Cluster\s*[\d]+:\s*//;
#print "line is:$line[$choice]\n";













