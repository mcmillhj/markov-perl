#!/usr/bin/perl

use strict;
use warnings; 

use Markov::Chain;
use Data::Dumper; 

die "Missing input file" 
    unless @ARGV == 1;

my $text;
{
   open my $fh, '<', $ARGV[0]; 
   local $/ = undef; 
   $text = <$fh>;
   close($fh);
}

my $c = Markov::Chain->new(text => $text);
$c->seed;
print $c->generate(50) . "\n";
