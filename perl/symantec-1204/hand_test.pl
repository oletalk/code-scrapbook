#!/opt/local/bin/perl

use Hand;
use Card;

use strict;

my $h = Hand->new();
my $SS = Card->SPADES;
my $SC = Card->CLUBS;
my $SH = Card->HEARTS;
my $SD = Card->DIAMONDS;

$h->add_card(Card->new('2', $SC));
$h->add_card(Card->new('8', $SC));
$h->add_card(Card->new('2', $SH));
$h->add_card(Card->new('Ace', $SD));
$h->add_card(Card->new('2', $SD));
$h->add_card(Card->new('3', $SD));
$h->add_card(Card->new('8', $SD));
chk($h);

$h = Hand->new();
$h->add_card(Card->new('2', $SC));
$h->add_card(Card->new('8', $SC));
$h->add_card(Card->new('2', $SS));
$h->add_card(Card->new('8', $SS));
$h->add_card(Card->new('6', $SH));
$h->add_card(Card->new('2', $SD));
$h->add_card(Card->new('8', $SD));
#$h->add_card(Card->new('Ace', $SD));
chk($h);

# 6---- 2:C 8:C 2:S 8:S 6:H 2:D 8:D
exit(0);

#########################
sub chk {
	my ($hand) = @_;
	print "(DEBUG) Hand count is " . $hand->check_hand() . "\n";
	print "Contents of hand: " . $hand->contents() . "\n";
	if ($hand->has_won()) {
		print "This is a winning hand!\n";
	}	
}
