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


unless ($#ARGV >= 2)
{
	die("Usage: extract.pl <itm_file> <pdb_file> <level>\n"); 
} 

$itmfile = $ARGV[0]; 
$pdbfile = $ARGV[1]; 
#$level = $ARGV[2];
#$level =~ s/\s+//g; 

#if ($ARGV[3]) 
#{
#	$hlevel = $ARGV[3]; 
#	$hlevel =~ s/\s+//g; 
#}

print STDERR "itmfile=$itmfile, pdbfile=$pdbfile\n"; 

open (infile, "<$pdbfile") || die "Cannot open $pdbfile. $!\n"; 
while (<infile>) 
{
	if (/^ATOM/)
	{
		($tmp, $num, $name, $amino, $tmp, $tmp, $tmp, $tmp) = split(/\s+/);
		unless ($num =~ /^[0-9]+$/) 
		{
			($tmp, $tmp, $name, $amino, $tmp, $num, $tmp, $tmp, $tmp) = split(/\s+/); 
		}
		unless ($recordhash{"$name:$num"})
		{
			$recordhash{"$name:$num"} = $_;
		}
		else 
		{
			#$recordhash{"$amino:$num"} .= $_; 
		}
	}
}
close(infile); 

open (infile, "<$itmfile") || die "Cannot open $itmfile. $!\n"; 
while (<infile>) 
{
	unless (/^INT/)
	{
	  s/^CND:[^:]*://; 
	  $rec = $_; 
#		($tmp,$l,$rec) = split(/:/); 
#		if ($l >= $level) 
		{
#			if ((!$hlevel) || ($hlevel && ($l <= $hlevel)))
			{
				$rec =~ s/\s+//g; 

				foreach $amino (split(/--/, $rec))
				{
				    $amino =~ s/\_([^\_]+)\_/:/; 
#					$amino =~ s/\_/:/; 
					if ($recordhash{$amino}) 
					{
						unless ($flaghash{$amino})
						{
							print $recordhash{$amino}; 
							$flaghash{$amino} = 1; 
						}
					}
					elsif ($amino =~ /^[CNO]:([0-9]+)/)
					{
						$id = $1; 
						my $allkeys = join(',', keys(%recordhash)); 
						if ($allkeys =~ /([CNO][^:]*:$id)(,|$)/)
						{
							$found = $1; 
							print $recordhash{$found}; 
							$flaghash{$found} = 1; 
						}
						else 
						{
							print STDERR "Something is wrong.. Cannot find C.*:$id... \n"; 
						}
					}
					else
					{
						print STDERR "Something is wrong. Amino acid $amino is not in the PDB file!\n"; 
					}
				}
			}
		}
	}
}

close(infile); 

exit 0; 

