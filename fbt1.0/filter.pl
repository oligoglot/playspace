#!/usr/bin/perl -w 

#
# filters a cluster 
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


my $tail = 0; 

if ($#ARGV > 0) 
  {
    $option = shift; 
    if ($option =~ /^tail=/)
      {
	$option =~ s/^tail=//; 
	$tail = 1; 
      }
  }

require gram_init; 

while(<>)
{
    if (/^Cluster\s+[0-9]+/) 
    {
	$line = $_; 
	$line =~ s/^(Cluster[^:]*)://; 
	my $c = $1; 

	$line =~ s/^\s+//; 
	$line =~ s/\s+$//; 
	
	print STDERR "Processing $c \n"; 
	my @files = split(/\s+/, $line); 
	my $numf = $#files + 1; 
	my $phash = {}; 
	my $path; 
	my $revpath; 

	unless ($numf <= 1) 
	{
		foreach $file (@files) 
		{
		  print STDERR "Opening $file...\n"; 
		  if (-f $file) 
		    {
		      open("infile", "<$file");
		      while (<infile>) 
			{
			  my $line = $_;
			  unless($line =~ /^INT/) 
			    {
			      my $path; 
			      my $revpath; 
			      
			      $edges ++;  # count number of edges
			      $line =~ s/^CND:[^:]*://; 
			      $line =~ s/\s+//g; 
			      $line =~ s/\n//g; 
			      
			      $path = pathify($line); 
			      $revpath = reverse_path($path); 
			      
			      $path = $revpath if $path gt $revpath; 
			      
			      if ($phash->{$path}) 
				{
				  $phash->{$path} .= " $file" unless $phash->{$path} =~ /\b$file\b/; 
				}
			      else 
				{
				  $phash->{$path} = "$file"; 
				}
			      
	# 	foreach $key (keys(%$phash))
	# 	  {
	# 	    print "$key  =>  $phash->{$key}\n"; 
	# 	  }
	# 	my $ch = <STDIN>; 

			    }
			}
		      close("infile"); 
		    }
		  else 
		    {
		      print STDERR "Skipping $file... No such file..\n"; 
		    }
		}

		foreach $key (keys(%$phash))
		{
		    my @kfiles = split(/\s+/,$phash->{$key}); 
		    my $numk = $#kfiles + 1; 

		    if (($numk*1000/$numf) < ($mc*1000)) 
		    {
		      print STDERR "Dropping: key = $key, numk = $numk, numf = $numf, mc = $mc\n"; 
	#	      $ch = <STDIN>;
			$phash->{$key} = ""; 
		    }
		    else 
		    {
			print STDERR "Retaining: key = $key, numk = $numk, numf = $numf, mc = $mc\n"; 
				  }
		}

		if ($tail == 1) 
		  {
		    while (shift(@files) ne "+") 
		      {}
		  }

		foreach $file (@files) 
		{
		  my $wflag = 0; 
		  if (-f $file) 
		    {
		      open("infile", "<$file"); 
		      open("outfile", ">$file.$$") || die "Cannot open $file.$$. $!\n"; 
		      
		      while (<infile>) 
			{
			  my $line = $_; 
			  unless(/^INT/) 
			    {
			      $line =~ s/^CND:[^:]*://; 
			      $line =~ s/\s+//g; 
			      
			      my $path = pathify($line); 
			      my $revpath = reverse_path($path); 
			      
			      $path = $revpath if $path gt $revpath; 
			      if ($phash->{$path}) 
				{
				  $wflag = 1; 
				  print outfile "$line\n"; 
				} 
			      else 
				{
				  $dedges ++;
				  print STDERR "Dropping $line from $file...\n"; 
				}
			    }
			}
		      close("infile"); 
		      close("outfile"); 
		      if ($wflag) 
			{
			  system("mv $file.$$ $file"); 
			  unlink "$file.$$"; 
			}
		      else 
			{
			  unlink "$file.$$"; 
			  unlink "$file"; 
			}
		    }
		  else 
		    {
		      print STDERR "$file is not a file..\n"; 
		    }
		}
	}
	else
	{
		print STDERR "$files[0] is a big blob. Ignoring...\n"; 
	}
    }
}

print "edges=$edges\n"; 
print "dedges=$dedges\n"; 
