package Markov::Chain; 
use Moose; 

use Data::Dumper;
 
has text    => (is => 'ro', isa => 'Str', required => 1);
has order   => (is => 'ro', isa => 'Int', default => 2);
has lexicon => (is => 'rw', isa => 'HashRef', default => sub { {} });

sub seed { 
   my $self = shift; 

   my @words = split /\s+/, $self->text;
   while (@words > $self->order) {
      my @gram = @words[0 .. $self->order];
      shift @words; 

      my $val = pop @gram; 
      my $key = join ' ', @gram; 

      push @{$self->lexicon->{$key}}, $val;
   }
}

sub generate {
   my ($self, $size) = @_;
   $size ||= 25;

   my @hashkeys  = keys %{$self->lexicon};
   my ($w1, $w2) = split / /, $hashkeys[rand @hashkeys]; 

   my @generated;
   foreach (0 .. $size) {
      push @generated, $w1;
      my @choices = @{$self->lexicon->{"$w1 $w2"}};
      ($w1, $w2) = ($w2, $choices[rand @choices]);
   }
   push @generated, $w2;

   return join ' ', @generated;
}

1; 

__END__

=head1 NAME 

Markov::Chain

=head1 DESCRIPTION

Given a scalar that contains a text sample (preferably a large one), generates new text
from the sample using Order-2 Markov Chains

=head1 METHODS

=over 4

=item seed

"seed" the text generator by creating Order-2 Markov Chains from the sample text. 
This step generates a hashref where the keys are every 2-word phrase in the sample text, and 
the values an arrayref of all the values that follow those 2-word phrases in the text. 

For example, given a text of:
   "If debugging is the process of removing software bugs, then programming must be the process of putting them in"

   {  'of putting'        => ['them'],
      'must be'           => ['the'],
      'is the'            => ['process'],
      'then programming'  => ['must'],
      'If debugging'      => ['is'],
      'be the'            => ['process'],
      'bugs, then'        => ['programming'],
      'putting them'      => ['in'],
      'programming must'  => ['be'],
      'debugging is'      => ['the'],
      'software bugs,'    => ['then'],
      'removing software' => ['bugs,'],
      'the process'       => ['of','of'],
      'process of'        => ['removing','putting'],
      'of removing'       => ['software'],
   };

=item generate

"creates" new text based on the sample text and Order-2 Markov Chain hashref above by
choosing a random starting place then "chaining" through the hashref by combining words. 

For example, if we started with word1 = 'of' and word2 = 'putting', we would save word1
as the first word of the new text. Word1 and word2 are combined to get a list of values
to choose a new word from in this case "of putting" gives a single value 'them' which is then 
chosen to become the new word2, if there were more than a single value it would be chosen 
randomly. Word2 becomes the new word1 and the process repeats until we reach a new text
of the specified size.

=back

=cut

