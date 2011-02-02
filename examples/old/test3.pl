#!/usr/bin/perl

use Tie::Array::Iterable;

my @array = ( 1, 2, 3 );

my $iterarray = new Tie::Array::Iterable(@array);

print Dumper($iterarray); use Data::Dumper;

push @$iterarray, 5;

print Dumper($iterarray); use Data::Dumper;

#   for( my $iter = $iterarray->start() ; !$iter->at_end() ; $iter->next() ) {
#         print $iter->index(), " : ", $iter->value();
#         if ( $iter->value() == 3 ) {
#                 unshift @$iterarray, (11..15);
#         }
#   }

