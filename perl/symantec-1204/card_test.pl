#!/opt/local/bin/perl

use Hand;
use Card;

use strict;

my $c1 = Card->new('8', Card->HEARTS);
my $c2 = Card->new('9', Card->HEARTS);
my $c3 = Card->new('8', Card->CLUBS);
my $c4 = Card->new('10', Card->DIAMONDS);
my $c5 = Card->new('Jack', Card->SPADES);
my $c6 = Card->new('Queen', Card->SPADES);
my $c7 = Card->new('King', Card->SPADES);

my $h = new Hand();

print "Compare card 1 to card 2.\n";
if ($c1->compare_suit($c2) == 0 ) {
	print "They are the same suit.\n";
}

unless ($c1->compare_suit($c3) == 0 ) {
	print "Card 1 and card 3 are NOT the same suit.\n";
}

print "Compared ranks for Card 1 and Card 2: ";
print $c1->compare_rank($c2) . "\n";

my @a = ($c1, $c2, $c3, $c4, $c5, $c6, $c7);
my @b = sort { $a->combined_val() <=> $b->combined_val() } @a;

foreach (@b) {
	$h->add_card($_);
}

$h->check_hand();
$h->display_want_list();

print "List of cards UNsorted: " . printcards(\@a, $h) . "\n";
print "List of cards   sorted: " . printcards(\@b, $h) . "\n";


my $c8 = Card->new('10', Card->HEARTS);
print "Here is a 10 of Hearts, which we DO want\n" if $h->wants($c8);

my @eights = $h->all_cards_with_rank('King');
foreach (@eights) {
	print $_->long_descr() . "\n";
}

print "\n\n";
print $h->card_index("10:D");
exit(0);
######################################

sub printcards {
	my ($arr, $hand) = @_;
	my $ret = "";
	foreach (@$arr) {
		$ret .= "\n   -> " . $_->long_descr(). " ";
		$ret .= " <- can drop this" if ($h->can_drop($_));
	}
	$ret;
}