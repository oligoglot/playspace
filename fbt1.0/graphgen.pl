#!/usr/bin/perl -w
# use strict;

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


die "Usage: graphgen <no of node labels> <no of edges> [name=graphname] [type=edgetype]\n" unless $#ARGV>=1;

my $nodetypes = shift;
my $edges = shift;
#$edges = 2 * $edges;
my $ratio = 2 * $edges / $nodetypes;
my $graphname = "art"; 
my $edgetype = "s"; 

while ($#ARGV >= 0)
{
	my $param = shift; 
	if ($param =~ /^name=/)
	{
		$param =~ s/^name=//; 
		$graphname = $param; 
	}
	elsif ($param =~ /^type=/)
	{
		$param =~ s/^type=//; 
		$edgetype = $param; 
	}
}

print "graph $graphname {\n";
my %nodelist;
my @nodecount;
my $i = int(rand($nodetypes));
my $node = "n".$i."_".int(rand($ratio));

$nodelist{$node} = 1;
$edges--;  # only a node is created but $edges is decremented 
my %pair;

while($edges>=0)
{
	for($i=0; $i<$nodetypes; $i++)
	{
		if($edges>=0)
		{
			my $start;
			$start = "n".$i."_".int(rand($ratio));
			while($start eq $node)
			{
				$start = "n".$i."_".int(rand($ratio));
			}
			$node = "";
			my $dest = $start;
			my @randlist = sort {rand(a) <=> rand(b)} keys %nodelist;
			while(($dest eq $start) or ($dest eq "") or ($pair{"$start:$dest"} == 1)) 
			{
			#	if($pair{"$start:$dest"}) { <STDIN>; }
				if($#randlist<0) 
				{ 
			#	print "\t$dest and $start\n";
					@randlist = sort {rand(a) <=> rand(b)} keys %nodelist;
					$start = "n".$i."_".int(rand($ratio));
				}
				$dest = shift @randlist;
			}
			$nodelist{$start} = 1;
			$pair{"$start:$dest"}=1;
			$pair{"$dest:$start"}=1;
			print "$start--$dest"."[type=$edgetype];\n";
		}
		$edges--;
	}
}
print "}\n";
